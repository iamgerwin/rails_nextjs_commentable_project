# frozen_string_literal: true

module Api
  module V1
    # Reactions controller with Ransack filtering and polymorphic support
    # Supports reactions (like, dislike, love, clap) on Videos, Posts, and Comments
    #
    # Ransack Examples:
    #   GET /api/v1/reactions?q[type_name_eq]=like
    #   GET /api/v1/reactions?q[reactable_type_eq]=Video
    #   GET /api/v1/reactions?q[user_username_cont]=john
    #   GET /api/v1/reactions?q[created_at_gteq]=2024-01-01&q[s]=created_at desc
    #   GET /api/v1/reactions?q[type_name_in][]=like&q[type_name_in][]=love
    #
    # Nested Routes:
    #   GET /api/v1/videos/:video_id/reactions
    #   POST /api/v1/videos/:video_id/reactions
    #   DELETE /api/v1/videos/:video_id/reactions/:id
    #   GET /api/v1/posts/:post_id/reactions
    #   POST /api/v1/posts/:post_id/reactions
    #   GET /api/v1/comments/:comment_id/reactions
    #   POST /api/v1/comments/:comment_id/reactions
    #
    class ReactionsController < BaseController
      before_action :authenticate_user!, except: [:index]
      before_action :authenticate_user, only: [:index]
      before_action :set_reactable, only: [:index, :create], if: -> { params[:video_id] || params[:post_id] || params[:comment_id] }
      before_action :set_reaction, only: [:destroy]
      before_action :authorize_reaction, only: [:destroy]

      # GET /api/v1/reactions
      # GET /api/v1/videos/:video_id/reactions
      # GET /api/v1/posts/:post_id/reactions
      # GET /api/v1/comments/:comment_id/reactions
      # List reactions with Ransack filtering
      def index
        base_scope = @reactable ? @reactable.reactions : Reaction.all

        @q = base_scope.ransack(params[:q])
        @reactions = @q.result(distinct: true)
                       .includes(:user)
                       .page(pagination_params[:page])
                       .per(pagination_params[:per_page])

        # Optionally group by reaction type for summary
        if params[:summary] == 'true'
          summary = @reactions.group(:type_name).count
          render_success(
            {
              summary: summary,
              total: @reactions.count
            }
          )
        else
          render_success(
            ActiveModel::Serializer::CollectionSerializer.new(
              @reactions,
              serializer: ReactionSerializer
            ).as_json,
            meta: pagination_meta(@reactions)
          )
        end
      end

      # POST /api/v1/videos/:video_id/reactions
      # POST /api/v1/posts/:post_id/reactions
      # POST /api/v1/comments/:comment_id/reactions
      # Create or toggle a reaction
      def create
        unless @reactable
          return render_error(
            'Reactable entity not found',
            code: 'REACTABLE_NOT_FOUND',
            status: :not_found
          )
        end

        # Check if user already reacted with same type
        existing_reaction = @reactable.reactions.find_by(
          user: current_user,
          type_name: reaction_params[:type_name]
        )

        if existing_reaction
          # Remove reaction if it already exists (toggle off)
          existing_reaction.destroy
          AuditLog.log_delete(existing_reaction, user: current_user)
          return render_success(
            {
              message: 'Reaction removed successfully',
              action: 'removed',
              type: reaction_params[:type_name]
            }
          )
        end

        # Remove any other reaction types from this user (only one reaction per user)
        @reactable.reactions.where(user: current_user).destroy_all

        # Create new reaction
        @reaction = @reactable.reactions.build(reaction_params)
        @reaction.user = current_user

        if @reaction.save
          AuditLog.log_create(@reaction, user: current_user)
          render_success(
            ReactionSerializer.new(@reaction).as_json.merge(
              message: 'Reaction added successfully',
              action: 'added'
            ),
            status: :created
          )
        else
          render_error(
            @reaction.errors.full_messages.join(', '),
            code: 'REACTION_CREATE_FAILED',
            status: :unprocessable_entity
          )
        end
      end

      # DELETE /api/v1/reactions/:id
      # Remove a reaction
      def destroy
        if @reaction.destroy
          AuditLog.log_delete(@reaction, user: current_user)
          render_success({ message: 'Reaction removed successfully' })
        else
          render_error(
            'Failed to remove reaction',
            code: 'REACTION_DELETE_FAILED',
            status: :unprocessable_entity
          )
        end
      end

      private

      def set_reactable
        if params[:video_id]
          @reactable = Video.find(params[:video_id])
        elsif params[:post_id]
          # Support both ID and slug for posts
          @reactable = if params[:post_id].match?(/^\d+$/) || params[:post_id].match?(/^[0-9a-f]{8}-/)
                         Post.find(params[:post_id])
                       else
                         Post.find_by!(slug: params[:post_id])
                       end
        elsif params[:comment_id]
          @reactable = Comment.find(params[:comment_id])
        end
      rescue ActiveRecord::RecordNotFound
        render_error(
          'Reactable entity not found',
          code: 'REACTABLE_NOT_FOUND',
          status: :not_found
        )
      end

      def set_reaction
        @reaction = Reaction.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render_error(
          'Reaction not found',
          code: 'REACTION_NOT_FOUND',
          status: :not_found
        )
      end

      def authorize_reaction
        authorize @reaction
      end

      def reaction_params
        params.require(:reaction).permit(:type_name)
      end
    end
  end
end
