require 'pry'

class CatsController < ApplicationController
  skip_before_action :verify_authenticity_token

  before_action :load_cat_of_the_month, only: :index
  before_action :load_cat, only: [ :show, :edit, :update]
  before_action :retrieve_cat_user, only: [:index, :show, :edit, :edit_cat_user, :update, :destroy]
  before_action :redirect_logged_in, only: [:new, :create, :login, :authenticate ]

  def index
    page  = params[:page].to_i || 1
    @cat_user = Cat.find(session[:cat_id])
    # page scope is provided by kamikari gem
    # https://github.com/amatsuda/kaminari/blob/master/lib/kaminari/models/active_record_model_extension.rb#L13
   
      @cats = Cat.cat_info.page(page)

  end
  def authenticate
    cat_login = params.require(:cat).permit(:email, :password)
    cat = Cat.find_by(email: cat_login[:email]).try(:authenticate, cat_login[:password])
    

    if !cat
      @cat = Cat.new(email: cat_login[:email])
      render ('login')
    else
      session[:cat_id] = cat.id
      redirect_to(cats_path)
    end

  end

  def new
    @cat = Cat.new
  end

  def login
    @cat = Cat.new
  end


  def show
  end

  def edit
    unless params[:id].to_i == session[:cat_id]
      redirect_to(edit_cat_user_path)
    end
  end

  def edit_cat_user
    @cat = @cat_user
    render('edit')
  end


  def update
    if params[:id].to_i == session[:cat_id]
      if @cat.update(cats_params)
        flash[:notice] = "Cat updated successfully"

        redirect_to cat_path(@cat)
      else
        flash[:error]  = "Ops! We couldn't update the cat, please review the errors"

        render :edit
      end
    else
        redirect_to(edit_cat_user_path)
    end
  end

  def create
      @new_cat_info = params.require(:cat).permit(:name, :email, :password)
      @cat = Cat.new(@new_cat_info)
      if @cat.save
        redirect_to (login_path)
      else
        render 'new'
    end

  end


  private

  def load_cat
    @cat = Cat.where("id = #{params[:id]}").visible.first

    render text: 'Not Found', status: '404' unless @cat
  end

  def cats_params
    { visible: true }.merge(params[:cat])
  end



  # Do you think this is a good place to put this logic?
  # Where would you move it?
  def load_cat_of_the_month
      month = DateTime.now.last_month.strftime('%Y-%B')
    @cats = Rails.cache.fetch("cat-of-the-month/#{month}", expires_in: 1.month) do

  
      last_month_follower_relation = FollowerRelation.where("EXTRACT(MONTH FROM created_at) = ? AND EXTRACT(YEAR FROM created_at) = ?", 1.month.ago.month, 1.month.ago.year)

      # First alternative
      # Retrieve results from database without order and use ruby function to order hash
      count_of_followers = last_month_follower_relation.group(:followed_cat_id).count
      # http://www.rubyinside.com/how-to/ruby-sort-hash
      cat_of_the_month_data = count_of_followers.sort_by { |k, v| -v }.first
      @cat_of_the_month = Cat.find(cat_of_the_month_data.first) if cat_of_the_month_data

      # # Second alternative
      # # Order the results with SQL query an retrieve one result
      # # I just googled "Order by group by count" to find this solution
      # cat_of_month_id = last_month_follower_relation.
      #   group(:followed_cat_id).
      #   select("followed_cat_id, COUNT(*) as followers_count").
      #   order("followers_count DESC").
      #   limit(1).first.try(:followed_cat_id)
      #
      # # http://apidock.com/rails/Object/try
      #
      # @cat_of_the_month = Cat.find(cat_of_month_id) if cat_of_month_id
    end
  end

  def redirect_logged_in
    @cat_user = Cat.find_by(id: session[:cat_id])
    if @cat_user.present?
      redirect_to(cats_path)
    end

  end

  def retrieve_cat_user
    @cat_user = Cat.find_by(id: session[:cat_id])

    if @cat_user.nil?
      redirect_to(login_path)
    end
  end

end
