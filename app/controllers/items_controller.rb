class ItemsController < ApplicationController
  def new
    @item = Item.new
    render :form
  end

  def show
    @item = current_user.items.find(params[:id])
  end

  def index
    @items = current_user.items.all
  end

  def create
    @item = Item.new(item_params)
    @item.user = current_user

    if @item.create_with_reverse
      flash[:success] = "Item successfully created"
      redirect_to root_path
    else
      flash[:error] = helpers.model_errors_as_html(@item)
      redirect_to new_item_path
    end
  end

  def edit
    @item = current_user.items.find(params[:id])

    render :form
  end

  def update
    @item = current_user.items.find(params[:id])

    if @item.update(item_params)
      flash[:success] = "Item successfully updated"
    else
      flash[:error] = "An error occured"
    end

    redirect_to item_path(@item)
  end

  def destroy
    @item = current_user.items.find(params[:id])

    if @item.destroy
      flash[:success] = "Item successfully deleted"
    else
      flash[:error] = "An error occured"
    end

    redirect_to root_path
  end

  def next
    next_item = current_user.items.next

    if next_item
      redirect_to item_path(next_item)
    else
      redirect_to no_next_items_path
    end
  end

  def no_next
  end

  def search
    sql_query = params[:query].downcase
    @items = current_user.items.where('lower(text_1) like ? or lower(text_2) like ?', "%#{sql_query}%", "%#{sql_query}%")

    if @items.size > 0
      flash.clear
      render :index
    else
      flash[:error] = "No results found for your search."
      @item = Item.new(text_1: params[:query])
      render :form
    end
  end

  def pending
    @items = current_user.items.pending
    render :index
  end

  def answer
    @item = current_user.items.find(params[:id])
    is_answer_correct = params[:is_answer_correct] == "true"
    @item.set_level_regarding_answer(is_answer_correct)
    @item.set_next_answer_at_after_answer
    @item.last_answer_at = Date.today

    if @item.save
      current_user.push_in_progress_bar(is_answer_correct)

      level_evolution_type = is_answer_correct ? 'up' : 'down'
      current_user.update_levels_evolution(@item.level, level_evolution_type)

      if is_answer_correct
        flash[:success] = "Well done!"
      else
        flash[:success] = "Maybe next time!"
      end
    else
      flash[:error] = "An error occured"
    end

    if current_user.progress_bar_data.empty?
      redirect_to landing_items_path
    else
      redirect_to next_items_path
    end
  end

  def landing
    @counts_by_level = current_user.items.counts_by_level
    @counts_waiting_answer_by_level = current_user.items.to_show_today.counts_by_level
  end

  def reset_to_zero
    @item = current_user.items.find(params[:id])
    @item.update level: 0
    @item.save

    redirect_to item_path(@item)
  end

  def shift
    @item = current_user.items.find(params[:id])
    @item.shift

    redirect_to next_items_path
  end

  private

  def item_params
    params.require(:item).permit(:text_1, :text_2)
  end
end
