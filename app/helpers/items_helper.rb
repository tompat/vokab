module ItemsHelper
  def level_evolution_badge_value(level, evolution_type)    
    value = current_user.levels_evolution.try(:[], "level_#{level}").try(:[], evolution_type)
    
    if value == 0 || value.nil?
      return "="
    else
      return "+ #{value}"
    end
  end
end
