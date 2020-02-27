class ItemsController < ApplicationController
  before_action :move_to_root, except: [:index]
  before_action :set_item, only:[:show,:destroy,:edit,:update]

  def index
    @items = Item.includes(:images).order('created_at DESC').limit(3)
    @q     = @items.ransack(params[:q])
    @items = @q.result(distinct: true)
  end

  def search
    
  end

  def show
    @saler = @item.saler
    @brand = @item.brand
    @category = @item.category
    @images =  @item.images
  end

  def new
    @item = Item.new
    @item.images.new
    @category_parent_array = ["--"]
    Category.where(ancestry: nil).each do |parent|
      @category_parent_array << parent.name
    end
    respond_to do |format|
      format.html
      format.json
     end
  end

  def get_category_children
    @category_children = Category.find_by(name: "#{params[:parent_name]}", ancestry: nil).children
  end
  
  def get_category_grandchildren
  @category_grandchildren = Category.find("#{params[:child_id]}").children
  end


  def create
    @item = Item.new(item_params)
    if @item.save
      redirect_to root_path
    else
      redirect_to new_item_path
    end
  end


  def edit
    @grandchild = @item.category
    @child = @grandchild.parent
    @parent = @grandchild.parent.parent
    @category_grandchild_array = ["--"]
    Category.where(ancestry: @grandchild.ancestry).each do |grandchild|
      @category_grandchild_array << grandchild.name
  end

  @category_child_array = ["--"]
  Category.where(ancestry: @child.ancestry).each do |child|
    @category_child_array << child.name
  end

  @category_parent_array = ["--"]
  Category.where(ancestry: nil).each do |parent|
    @category_parent_array << parent.name
  end
    @category = @item.category
    @child_categories = Category.where('ancestry = ?', "#{@category.parent.ancestry}")
    @grand_child = Category.where('ancestry = ?', "#{@category.ancestry}")
  end

  def update
    @item = Item.find(params[:id])
    if @item.update(item_params)
      redirect_to root_path,data: {confirm:"登録した商品情報を変更しました"}
    else
      render :edit
    end
  end

  def destroy
    if @item.destroy
      redirect_to root_path
    else
      redirect_to item_path(@item)
    end
  end

  private

  def item_params
    params.require(:item).permit(:name,:description,:category_id,:price,:condition,:derivery_charge,:days,:prefecture_id,:brand_id,images_attributes:[:id,:_destroy,:image]).merge(saler_id: current_user.id,buyer_id: nil)
  end

  def set_item
    @item = Item.find(params[:id])
  end

  def move_to_root
    redirect_to action: :index unless user_signed_in?
  end

  
end

