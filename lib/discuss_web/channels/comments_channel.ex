defmodule Discuss.CommentsChannel do
    use DiscussWeb, :channel
    alias Discuss.Notes.{Topic, Comment}
    alias Discuss.Repo

    def join("comments:" <> topic_id, _params, socket) do
        
        topic_id = String.to_integer(topic_id)
       # topic = Repo.get(Topic, topic_id)

       # THis tells you, when you join the socket, go and find
       # a Topic with this given id. ANd when you find that topic,
       # go to the comments table ang get the records with a topic id
       # like this.
       # The "preload" function means load up the association that 
       # is tied to the given topic_id

        topic = Topic
            |> Repo.get(topic_id)
            #|> Repo.preload(:comments)
            # Find up the given topic, load up the list of comments 
            # and inside of each of the comments, load up the association for user 
            # that that comments belongs to 
            |> Repo.preload(comments: [:user])

        #{:ok, %{}, socket}
        #assign the topic to the socket. This will be fetch later in the handle_in function
        {:ok, %{comments: topic.comments}, assign(socket, :topic, topic)}
    end

    def handle_in(name, %{"content" => content}, socket) do
        # get the topic assigned to the socket
        topic = socket.assigns.topic
        user_id = socket.assigns.user_id
        # IO.puts("%%%%%%%%%%%%%%%%%%%%%")
        # IO.inspect(socket.assigns.topic)
        # IO.puts("###########################")

        changeset = topic
            |> Ecto.build_assoc(:comments, user_id: user_id) # add comments and user_id to the topic
            |> Comment.changeset(%{content: content})

        case Repo.insert(changeset) do
            {:ok, comment} ->
                broadcast!(socket, "comments:#{socket.assigns.topic.id}:new", 
                    %{comment: comment})
                {:reply, :ok, socket}
            {:error, _reason} ->
                {:reply, {:error, %{errors: changeset}}, socket}    
        end
    end
end