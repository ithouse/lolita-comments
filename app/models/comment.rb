class Comment < ActiveRecord::Base
  include CollectiveIdea::Acts::NestedSet

  attr_accessor :moved
  acts_as_nested_set :dependent=>:destroy
  belongs_to :commentable, :polymorphic=>true
  belongs_to :commentator, :polymorphic=>true
  validates :commentable_type, :commentable_id, :commentator_name, :email, :body, :presence=>true

  before_validation :strip_html
  after_create :update_counter
  after_destroy :decrement_counter
  
  after_create :reply_if_needed
  after_create :move_in_tree
  after_save :update_answer_tags # NB! remove from plugin specific to project

  delegate :project, :to=>:commentable
  
  scope :by_commentable,lambda{|object|
    where(:commentable_type=>object.class.to_s, :commentable_id=>object.id)
  }
  
  def reply_with(attributes_or_comment)
    self.class.transaction do
      if attributes_or_comment.is_a?(self.class)
        attributes_or_comment.commentable=self
        attributes_or_comment.move_to_child_of(self)
        attributes_or_comment.save!
      elsif attributes_or_comment.is_a?(Hash)
        attributes_or_comment.merge!(:commentable=>self)
        self.class.create!(attributes_or_comment).move_to_child_of(self)
      else
        raise ArgumentError, "Can reply only with attributes Hash or other comment!"
      end
      self.increment!(:reply_count)
    end
    self.moved=true
  end

  def self.real_commentable(object)
    object.class==Comment ? object.root.commentable : object
  end

  # Return comment count for commentable object.
  # When commentable object has counter column that there is no need for
  # selection from DB. Otherwise find look in reflections for comment reflections
  def self.comment_count_for(commentable)
    if counter_column=self.counter_column_for(commentable)
      commentable.send(counter_column.to_sym)
    else
      if reflection=commentable.class.reflections.detect{|name,r| r.klass==self.class}
        commentable.send(reflection.first).count
      else
        raise ArgumentError, "Don't know how to get comment count for #{commentable.class}"
      end
    end
  end

  protected

  def self.counter_column_for(object)
    object.class.column_names.detect{|c| c=="comment_count" || c=="comments_count"}
  end
  
  private

  def move_in_tree
    unless self.moved
      last=self.class.by_commentable(commentable).order("created_at desc").first
      if last && last.id!=self.id
        self.move_to_right_of(last)
      else
        self.move_to_root
      end
    end
  end
  
  def reply_if_needed
    if commentable_type.to_s=="Comment"
      self.moved=true
      commentable.reply_with(self)
    end
  end

  def update_counter
    update_object_counter(commentator)
    update_object_counter(commentable)
  end

  def decrement_counter
    update_object_counter(commentator,true)
    update_object_counter(commentable,true)
  end

  def update_object_counter(object,destroyed=false)
    if object
      object=self.class.real_commentable(object)
      counter_column=self.class.counter_column_for(object)
      if counter_column
        diff=destroyed ? -1 : 1
        current_counter=object.send(:"#{counter_column.to_sym}").to_i+ diff
        object.send(:"#{counter_column.to_sym}=",current_counter)
        object.save!(:validate=>false)
        object.reload
      end
    end
  end

  def strip_html
    self.body.to_s.gsub!(/<\/?.*?>/, "")
  end
  
  def update_answer_tags #TODO remove from plugin
    real_commentable=self.class.real_commentable(commentable)
    if real_commentable.is_a?(Answer)
      old_tags=real_commentable.tag_list
      new_tags=old_tags+(ActsAsTaggableOn::Tag.tags_from(self.body,:project=>real_commentable.project)-old_tags)
      real_commentable.tag_list=new_tags
      real_commentable.save
    end
  end
end
