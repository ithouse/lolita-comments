class CommentsController < ApplicationController
  before_filter :authenticate_user!, :except=>[:index,:show,:new,:create,:reply]
  before_filter :set_commentable, :only=>[:new,:create,:index]
  before_filter :set_comment, :only=>[:reply,:destroy]
  load_and_authorize_resource :comment
  respond_to :js, :html

  def index
    respond_with @comments do |format|
      format.js{render}
      format.html{redirect_to :back}
    end
  end

  def reply
    @commentable=@comment
    respond_with(@comment)
  end
  
  def new
    respond_with @comment
  end

  def create
    can?(:create,Comment.new,@commentable)
    if !can?(:create,Comment.new,@commentable)
      render :nothing=>true, :status=>404
    else
      @comment.commentator=current_user if user_signed_in?
      @comment.commentable=@commentable
      if ((!user_signed_in? && verify_recaptcha(:model => @comment,:timeout=>5)) || user_signed_in?) && @comment.save
        flash.now[:notice] = 'Successfully created comment'.t
      end
      respond_with @comment do |format|
        format.js do
          return render if @comment.errors.empty?
          render :action=>:new
        end
      end
    end
  end

  def edit

  end

  def update

  end
  
  def destroy
    @ids=@comment.self_and_descendants.map(&:id)
    @commentable=@comment.commentable
    @comment.destroy
    flash.now[:notice] = I18n.t('Successfully destroyed comment')
    respond_with @comment do |format|
      format.js { render }
      format.html { redirect_to :back}
    end
  end

  private

  def set_comment
    @comment=Comment.find_by_id(params[:comment_id])
  end
  
  def set_commentable
    data=request.path.match(/(\/\w+\/\d+)(\/comments)/)[1].gsub(/^\//,"")
    parts=data.split("/")
    class_name=parts.first.singularize.camelize
    id=parts.last.to_i
    @commentable=class_name.constantize.find(id)
  end
end
