class Item < ApplicationRecord
  validate :at_least_one_text?

  scope :not_pending, -> { where('text_1 != ? and text_2 != ?', '', '') }
  scope :pending, -> { where('text_1 = ? or text_2 = ?', '', '') }

  belongs_to :user
  belongs_to :reverse_item, class_name: 'Item', foreign_key: 'reverse_item_id', optional: true

  after_update(:set_reverse_item_if_necessary)

  LEVEL_MAX = 4
  LEVEL_COUNT = LEVEL_MAX + 1

  LEVEL_DURATION = {
    0 => 1.day,
    1 => 1.day,
    2 => 7.days,
    3 => 30.days,
    4 => 180.days
  }

  def at_least_one_text?
    if text_1.blank? && text_2.blank?
      errors.add :base, "At least one text must be present"
    end
  end

  def set_level_regarding_answer(is_answer_correct)
    if is_answer_correct && level < LEVEL_MAX
      update level: level + 1
    elsif !is_answer_correct
      update level: 0
    end
  end

  def set_next_answer_at_after_answer
    self.next_answer_at = Date.today + LEVEL_DURATION[level]
  end

  def self.next
    items = self.to_show_today
    not_level_max_item_ids = items.where.not(level: LEVEL_MAX).ids
    items = items.where.not(level: LEVEL_MAX) if not_level_max_item_ids.size > 0
    items = items.order('last_answer_at is not null, last_answer_at ASC')
    items.first
  end

  def self.waiting_answer
    item_ids = where(next_answer_at: nil).or(Item.where('next_answer_at < ?', DateTime.now)).ids
    reverse_item_ids = Item.where(id: item_ids).pluck(:reverse_item_id)
    item_ids_to_exclude = Item.where(id: reverse_item_ids).where('last_answer_at >= ?', 3.days.ago.to_date).pluck(:reverse_item_id)
    Item.where(id: item_ids).where.not(id: item_ids_to_exclude).where.not(text_2: "")
  end

  def self.to_show_today
    items = waiting_answer
    item_ids = waiting_answer.ids
    item_ids_to_exclude = []

    items.pluck(:id, :reverse_item_id).each do |item_id, reverse_item_id|
      if !item_id.in?(item_ids_to_exclude) && reverse_item_id.in?(item_ids)
        item_ids_to_exclude << reverse_item_id
      end
    end

    items.where.not(id: item_ids_to_exclude)
  end

  def self.counts_by_level
    counts = group(:level).count.to_h

    LEVEL_COUNT.times.each_with_index do |index|
      counts[index] = 0 if !counts.has_key?(index)
    end

    counts
  end

  def create_with_reverse
    Item.transaction do
      self.next_answer_at = DateTime.now + 1.day
      self.save

      if self.text_2.present?
        create_reverse_item
        return self.valid? && self.reverse_item.valid?
      else
        return self.valid?
      end
    end
  end

  def create_reverse_item
    new_reverse_item = Item.create(text_1: self.text_2, text_2: self.text_1, user_id: self.user_id, next_answer_at: DateTime.now + 4.days, reverse_item: self)
    self.update(reverse_item: new_reverse_item)
  end

  def set_reverse_item_if_necessary
    if self.reverse_item.nil? && self.text_2.present?
      create_reverse_item
    end
  end

  def shift
    self.update last_answer_at: Date.today, next_answer_at: (Date.today + 3.days)
  end
end
