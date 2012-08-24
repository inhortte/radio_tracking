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
  STRFDATE = "%d %m %Y"
  STRFTIME = "%d %b %Y %H:%M"
  MYSQLDATE = "%Y-%m-%d"
  MYSQLTIME = "%H:%M"
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
    params['release_location_E'] = params['release_location_E'].to_f
    params['release_location_N'] = params['release_location_N'].to_f
    params['birthdate'] = Time.now.strftime(MYSQLDATE) if params['birthdate'].empty?
    params['release_date'] = Time.now.strftime(MYSQLDATE) if params['release_date'].empty?
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
  get '/released_animal/:id/delete' do
    logger.info "DELETING ... #{ReleasedAnimal.get(params['id']).nickname}"
    ra = ReleasedAnimal.get(params['id'])
    ra.destroy
  end

  get('/radiotracking') { redirect '/forms/track' }
  get '/track' do
    # @rts = Radiotracking.all(:order => [:nickname.asc])
    haml :rt_index
  end
  get '/track/animal/:id' do
    # @rts = Radiotracking.all(:order => [:nickname.asc])
    @ra_id = params['id'].to_i
    haml :rt_index
  end
  get('/track/new') { haml :rt_new }
  get '/track/:id' do
    @rt = Radiotracking.get(params[:id])
    if @rt
      haml :rt_edit
    else
      haml :rt_new
    end
  end
  post '/track' do
    logger.info "POST radiotracking data!"
    params['activity'] = params['activity'] ? true : false
    time = params.delete('time')
    params['date'] += " #{time}"
    logger.info params.inspect
    rt = Radiotracking.new(params)
    if rt.save
      flash[:notice] = "#{params['nickname']} radiotracking by #{Observer.get(params['observer_id']).observer} saved"
      redirect "/forms/track/animal/#{rt.released_animal.id}"
    else
      flash[:notice] = "There was a problem saving radiotracking data: #{params['nickname']} by #{Observer.get(params['observer_id']).observer}"
      redirect '/forms/track/new'
    end
  end
  post '/track_edit' do
    logger.info "PUT radiotracking!"
    params['activity'] = params['activity'] ? true : false
    time = params.delete('time')
    params['date'] += " #{time}"
    logger.info params.inspect
    rt = Radiotracking.get(params["id"])
    if rt
      if rt.update(params)
        flash[:notice] = "#{params['nickname']} radiotracking by #{Observer.get(params['observer_id']).observer} updated"
        redirect "/forms/track/animal/#{rt.released_animal.id}"
      else
        flash[:notice] = "The update failed"
        redirect '/forms/track'
      end
    else
      redirect '/forms/track/new'
    end
  end
  get '/track/:id/delete' do
    logger.info "DELETING ... radiotracking...."
    rt = Radiotracking.get(params['id'])
    rt.destroy
  end
end

namespace '/ajax' do
  # get released_animal by id
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
  # this is the released_animal id
  get '/rt/:id' do 
    @rts = Radiotracking.all(:released_animal_id => params['id'],
                             :order => [:date.asc])
    haml :buliimia, :layout => false
  end
  # released_animal id from radiotracking id
  get '/ra_id/:rt_id' do
    ra_id = Radiotracking.get(params['rt_id']).released_animal.id
    ra_id.to_json
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
  def options_for_nicknames_to_ids(id = nil)
    ReleasedAnimal.all(:order => [:nickname.asc]).inject("") do |mem, ra|
      mem += "<option value=\"#{ra.id}\" #{ra.id == id ? 'selected=\"selected\"' : ''}>#{ra.nickname.empty? ? '...' : ra.nickname}</option>"
    end
  end
  def options_for_animal_ids(id = nil)
    ReleasedAnimal.all(:order => [:animal_id.asc]).inject("") do |mem, ra|
      mem += "<option value=\"#{ra.id}\" #{ra.id == id.to_i ? 'selected=\"selected\"' : ''}>#{ra.animal_id}</option>"
    end
  end
  def options_for_frequencies(freq = nil)
    ReleasedAnimal.all(:order => [:frequency.asc]).inject("") do |mem, ra|
      mem += "<option value=\"#{ra.id}\" #{ra.id == id.to_i ? 'selected=\"selected\"' : ''}>#{ra.frequency}</option>"      
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
