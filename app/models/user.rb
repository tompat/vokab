class User < ApplicationRecord
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :validatable, :confirmable, :trackable

  has_many :items

  def is_me?
    email == 'th.patris@gmail.com'
  end

  def push_in_progress_bar(is_answer_correct)
    if self.progress_bar_data.size == 9
      self.update(progress_bar_data: [])
    else
      self.update(progress_bar_data: self.progress_bar_data.push(is_answer_correct))
    end
  end

  def counter
    self.items.to_show_today.count
  end

  def update_levels_evolution(new_level, evolution_type)
    level_key = "level_#{new_level}"

    self.levels_evolution = {} if self.progress_bar_data.size == 1
    self.levels_evolution[level_key] ||= {'down' => 0, 'up' => 0}
    self.levels_evolution[level_key][evolution_type] += 1
    self.save
  end
end
