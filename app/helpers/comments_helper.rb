module CommentsHelper

  def all_comments_show? commentable, limit
    (commentable.comments.count <= limit)    
  end

  def smart_commentable_title(commentable)
    commentable.is_a?(Comment) ? t(".title_reply") : t(".title_comment")
  end

  def commentable_object commentable
    if commentable.class.to_s=="Comment"
      commentable.root.commentable
    else
      commentable
    end
  end

  def commentable_id commentable
    commentable=commentable_object(commentable)
    "#{commentable.class.to_s.downcase}_#{commentable.id}"
  end

  def comments_with_level(commentable,limit=nil)
    limit||=1
    roots=Comment.roots.by_commentable(commentable).limit(limit)
    unless roots.empty?
      roots.each do |root|
        Comment.each_with_level(root.self_and_descendants) do |comment, level|
          yield comment,level
        end
      end
    end
  end

  def commentable_path(*args)
    name=[]
    options=args.extract_options! || {}
    action=options.delete(:action)
    singular=options.delete(:singular)
    args.each{|object|
      new_name=object.class.to_s.singularize.downcase
      name << new_name
      options[:"#{new_name}_id"]=object.id
    }
    name<<(action || singular ? "comment" : "comments")
    method="#{action}#{action ? "_" : ""}"+name.join("_")+"_path"
    send(method.to_sym,options)
  end
end
