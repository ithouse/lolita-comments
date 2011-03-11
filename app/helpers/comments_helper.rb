module CommentsHelper

  def all_comments_show? commentable, limit
    (commentable.comments.count <= limit)    
  end

  def smart_commentable_title(commentable)
      commentable.is_a?(Comment) ? t(".title_reply") : t(".title_comment")      
  end
end
