class ProjectController < ApplicationController

    respond_to :html, :json

    def index

        respond_with(@actions = Action.all)

    end
    
    def create
    
        #passedData = ActiveSupport::JSON.decode(params)

        Action.create(
            :project_id => 1,
            :name => params[:label],
            :time => Date.today,
            :data => params[:data].to_json
        )

        render :text => "ok"

    end
end
