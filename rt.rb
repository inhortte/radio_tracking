require 'rubygems'
require 'bundler'
Bundler.require

# helpers go here
helpers = Dir.entries('./helpers').select { |h| h =~ /.rb$/ }
helpers.each do |helper|
  require File.join('./helpers', helper)
end

# models go here
%w{koik.rb}.each { |model| require "./models/#{model}" }

# enable :sessions
set :show_exceptions, true

configure do
  set :app_file, __FILE__
  set :root, File.dirname(__FILE__)
  set :static, :true
  set :public_folder, Proc.new { File.join(root, "public") }
  LOGGER = Logger.new('rt.log')
  STRFDATE = "%d %b %Y"
  STRFTIME = "%d %b %Y %H:%M"
  MYSQLTIME = "%Y-%m-%d"
end

DataMapper.setup(:default, 'mysql://localhost/saaremaa2012')
#DataMapper.repository(:default).adapter.resource_naming_convention = DataMapper::NamingConventions::Resource::Underscored
DataMapper.finalize

get '/rt.css' do
  headers 'Content-Type' => 'text/css; charset=utf-8'
  sass :"sass/rt"
end

namespace '/forms' do
  get '/animal' do
    redirect '/forms/released_animal'
  end
  get '/released_animal' do
    @ras = ReleasedAnimal.all(:order => [ :nickname.asc ])
    haml :ra_index
  end
  get('/released_animal/new') { haml :ra_new }
  get '/released_animal/:id' do
    @ra = ReleasedAnimal.get(params[:id])
    if @ra
      haml :ra_edit
    else
      haml :ra_new
    end
  end
  post '/released_animal' do
    logger.info "POST released animal!"
    logger.info params.inspect
    ra = ReleasedAnimal.new(params)
    if ra.save
      flash[:notice] = "#{params['nickname']} saved"
    else
      flash[:notice] = "There was a problem saving #{params['nickname']}"
    end
    redirect '/forms/released_animal'
  end
  post '/released_animal_edit' do
    logger.info "PUT released animal!"
    logger.info params.inspect
    ra = ReleasedAnimal.get(params["id"])
    if ra
      if ra.update(params)
        flash[:notice] = "#{params['nickname']} updated"
      else
        flash[:notice] = "The update failed"
      end
      redirect '/forms/released_animal'
    else
      redirect '/forms/released_animal'
    end
  end

  get('/radiotracking') { redirect '/forms/track' }
  get '/track' do
    @rts = Radiotracking.all(:order => [:nickname.asc])
    haml :rt_index
  end
  get('/track/new') { haml :rt_new }
end

namespace '/ajax' do
  # get by id
  get '/ra/:id' do
    ra = ReleasedAnimal.get(params[:id])
    if ra
      ra.attributes.to_json
    else
      nil.to_json
    end
  end
  # get by nickname
  post '/ra' do
    ra = ReleasedAnimal.first(:nickname => params['nickname'])
    if ra
      ra.attributes.to_json
    else
      nil.to_json
    end
  end
end

helpers do
  def format_date(s)
    Time.parse(s).strftime(STRFDATE)
  end
  def format_time(s)
    Time.parse(s).strftime(STRFTIME)
  end
  def options_for_nicknames(nn = nil)
    ReleasedAnimal.all(:order => [:nickname.asc]).inject("<option value=\"\"></option>") do |mem, ra|
      mem += "<option value=\"#{ra.nickname}\" #{ra.nickname == nn ? 'selected=\"selected\"' : ''}>#{ra.nickname}</option>"
    end
  end
  def options_for_animal_ids(id = nil)
    ReleasedAnimal.all(:order => [:nickname.asc]).inject("") do |mem, ra|
      mem += "<option value=\"#{ra.id}\" #{ra.id == id.to_i ? 'selected=\"selected\"' : ''}>#{ra.animal_id}</option>"
    end
  end
  def options_for_observers(id = nil)
    Observer.all(:order => [:id.asc]).inject("") do |mem, ra|
      mem += "<option value=\"#{ra.id}\" #{ra.id == id.to_i ? 'selected=\"selected\"' : ''}>#{ra.observer}</option>"
    end
  end
  def options_for_biotopes(id = nil)
    Biotope.all(:order => [:id.asc]).inject("") do |mem, ra|
      mem += "<option value=\"#{ra.id}\" #{ra.id == id.to_i ? 'selected=\"selected\"' : ''}>#{ra.biotope}</option>"
    end
  end
  def options_for_distance_from_waters(id = nil)
    DistanceFromWater.all(:order => [:id.asc]).inject("") do |mem, ra|
      mem += "<option value=\"#{ra.id}\" #{ra.id == id.to_i ? 'selected=\"selected\"' : ''}>#{ra.distance_from_water}</option>"
    end
  end
  def options_for_waterbody_types(id = nil)
    WaterbodyType.all(:order => [:id.asc]).inject("") do |mem, ra|
      mem += "<option value=\"#{ra.id}\" #{ra.id == id.to_i ? 'selected=\"selected\"' : ''}>#{ra.waterbody_type}</option>"
    end
  end
  def options_for_water_levels(id = nil)
    WaterLevel.all(:order => [:id.asc]).inject("") do |mem, ra|
      mem += "<option value=\"#{ra.id}\" #{ra.id == id.to_i ? 'selected=\"selected\"' : ''}>#{ra.water_level}</option>"
    end
  end
  def options_for_precipitations(id = nil)
    Precipitation.all(:order => [:id.asc]).inject("") do |mem, ra|
      mem += "<option value=\"#{ra.id}\" #{ra.id == id.to_i ? 'selected=\"selected\"' : ''}>#{ra.precipitation}</option>"
    end
  end
  def options_for_temperatures(id = nil)
    Temperature.all(:order => [:id.asc]).inject("") do |mem, ra|
      mem += "<option value=\"#{ra.id}\" #{ra.id == id.to_i ? 'selected=\"selected\"' : ''}>#{ra.temperature}</option>"
    end
  end
end