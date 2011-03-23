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
        flash.now[:notice] = I18n.t('Successfully created comment')
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

  def verify_recaptcha(options = {})
    if !options.is_a? Hash
      options = {:model => options}
    end

    env = options[:env] || ENV['RAILS_ENV']
    #return true if Recaptcha.configuration.skip_verify_env.include? env
    model = options[:model]
    attribute = options[:attribute] || :base
    private_key = options[:private_key] || Recaptcha.private_key
    raise ArgumentError, "No private key specified." unless private_key

    begin
      recaptcha = nil
      unless params[:recaptcha_challenge_field].strip.blank?
        Timeout::timeout(options[:timeout] || 3) do
          recaptcha = Net::HTTP.post_form URI.parse(Recaptcha.verify_url), {
            "privatekey" => private_key,
            "remoteip"   => request.remote_ip,
            "challenge"  => params[:recaptcha_challenge_field],
            "response"   => params[:recaptcha_response_field]
          }
        end
        answer, error = recaptcha.body.split.map { |s| s.chomp }
      else
        answer=nil
      end
      unless answer == 'true'
        flash[:recaptcha_error] = error
        if model
          model.valid?
          model.errors.add attribute, options[:message] || "Word verification response is incorrect, please try again."
        end
        return false
      else
        flash[:recaptcha_error] = nil
        return true
      end
    rescue Timeout::Error
      flash[:recaptcha_error] = "recaptcha-not-reachable"
      if model
        model.valid?
        model.errors.add attribute, options[:message] || "Oops, we failed to validate your word verification response. Please try again."
      end
      return false
    rescue Exception => e
      raise ArgumentError, e.message, e.backtrace
    end
  end # verify_recaptcha
end
