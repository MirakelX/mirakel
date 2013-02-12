class ListsController < ApplicationController
  include TasksHelper
  before_filter :authenticate_user!
  # GET /lists
  # GET /lists.json
  def index
    @lists = current_user.lists
    authorize! :read, @lists.first
    @lists= @lists.arrange

    respond_to do |format|
      format.html { redirect_to list_path(current_user.lists.first) }
      format.json { render json: List.json_tree(@lists) }
    end
  end

  def getOrder(list)
    case list.sortby
    when "priority"
      return "priority DESC"
    when "due"
      return "due DESC"
    else
      return "id ASC"
    end
  end


  # GET /lists/1
  # GET /lists/1.json
  def show
    @sortby='id'
    case params[:id]
    when "all"
      @tasks=Array.new(1)
      @done_tasks=Array.new(1)
      current_user.lists.each do |list|
        @tasks=@tasks.concat(list.tasks.find_all_by_done(false))
        @done_tasks=@done_tasks.concat(list.tasks.where(done: true).limit(50))
      end
      @tasks=@tasks[1..-1]
      @done_tasks=@done_tasks[1..-1]			
      @fehler=false
      @sortby='id'
    when "week"
      @list=current_user.lists.first
      @tasks=Task.getByDate(current_user.lists,(Date.new(1)..Date.today()+7))
    when "today"
      @list=current_user.lists.first
      @tasks=Task.getByDate(current_user.lists,(Date.new(1)..Date.today()))
      print @tasks
    else
      begin
        @list = current_user.lists.find(params[:id])
        @fehler=false
        order=getOrder(@list)
        puts "*"*500
        puts order
        authorize! :read, @list
        @tasks = @list.tasks.order(order).find_all_by_done(false)
        @done_tasks = @list.tasks.order(order).find_all_by_done(true)
        @sortby=@list.sortby
      rescue
        @fehler=true
      end
    end
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @list }
    end
  end


  # GET /lists/new
  # GET /lists/new.json
  def new
    @list = List.new
    authorize! :create, @list

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @list }
    end
  end

  # GET /lists/1/edit
  def edit
    @list = current_user.lists.find(params[:id])
    authorize! :update, @list
  end

  # POST /lists
  # POST /lists.json
  def create
    @list = current_user.lists.build(params[:list])
    authorize! :create, @list

    respond_to do |format|
      if @list.save
        format.html { redirect_to @list, notice: I18n.t('lists.create_success') }
        format.json { render json: @list, status: :created, location: @list }
      else
        format.html { render action: "new" }
        format.json { render json: @list.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /lists/1
  # PUT /lists/1.json
  def update
    @list = current_user.lists.find(params[:id])
    authorize! :update, @list

    respond_to do |format|
      if @list.update_attributes(params[:list])
        format.html { redirect_to @list, notice: I18n.t('lists.update_success') }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @list.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /lists/1
  # DELETE /lists/1.json
  def destroy
    @list = current_user.lists.find(params[:id])
    authorize! :destroy, @list
    @list.destroy

    respond_to do |format|
      format.html { redirect_to lists_url }
      format.json { head :no_content }
    end
  end

  def move_after
    @list= current_user.lists.find(params[:list_id])
    if params[:id].nil?
      move_to=current_user.lists.first
    else
      move_to=current_user.lists.find(params[:id])
    end
    @list.move_to_right_of(move_to)
    render json: []
  end
  def move_in
    @list= current_user.lists.find(params[:list_id])
    move_to=current_user.lists.find(params[:id])
    @list.move_to_child_of(move_to)
    render json: []
  end

  def changesort
    @list=current_user.lists.find(params[:list_id])
    @list.sortby=params[:sort]
    @list.save
    render json: [@list]
  end
end
