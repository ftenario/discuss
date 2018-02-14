
#Module plug
defmodule DiscussWeb.Plugs.SetUser do
    import Plug.Conn
    import Phoenix.Controller

    alias Discuss.Repo
    alias Discuss.Notes.User
    alias Discuss.Router.Helpers

    # Do some setup
    def init(_params) do
    end

    #Called with a conn and must return a conn
    #The _params here is not the same as the params in the controllers.
    # THis is the return value of the init() function
    def call(conn, _params) do
        #get_session comes from Phoenix.Controller
        user_id = get_session(conn, :user_id)

        cond do
                    # if the user_id is defined and Repo.get returns a user, then 
                    # asign  user to user variable
                    # Ex red = 1 && "red"
                    # red is equals to "red"
            user = user_id && Repo.get(User, user_id) ->
                #add the :user atom containing user to conn
                # assign comes from Plug.Conn
                assign(conn, :user, user)
                #Fetch the user like this
                # conn.assigns.user => user struct
            true ->
                # No user is assign
                assign(conn, :user, nil)
        end
    end
end