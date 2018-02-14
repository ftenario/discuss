defmodule DiscussWeb.TopicController do
  use DiscussWeb, :controller
  #use Ecto

  alias Discuss.Notes
  alias Discuss.Notes.Topic
  alias Discuss.Repo

  # Execute before any handler inside of this file (Topic Controller)
  # THis will not execute for PageController
  # And only if the requests is calling these actions
  plug DiscussWeb.Plugs.RequireAuth when action in [:new, :create, :edit, :update, :delete]

  #Create a function plug
  plug :check_topic_owner when action in [:update, :edit, :delete]

  def index(conn, _params) do
    IO.inspect(conn.assigns)

    topics = Notes.list_topics()
    render(conn, "index.html", topics: topics)
  end

  def new(conn, _params) do
    changeset = Notes.change_topic(%Topic{})
    render(conn, "new.html", changeset: changeset)
  end

  @doc """
    %{"topic" => topic_params} - is the pattern matching of passed request to "topic"
    This is just like:
    def create(conn, params) do
       %{"topic" => topic} = params 
    end

  """
  def create(conn, %{"topic" => topic_params}) do
    IO.inspect(conn.assigns.user)

    changeset = conn.assigns.user
    |> Ecto.build_assoc(:topics)
    |> Topic.changeset(topic_params)

#    case Notes.create_topic(topic_params) do
#    case Notes.create_topic(changeset) do
    case Repo.insert(changeset) do
      {:ok, topic} ->
        conn
        |> put_flash(:info, "Topic created successfully.")
        |> redirect(to: topic_path(conn, :index))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    topic = Notes.get_topic!(id)
    render(conn, "show.html", topic: topic)
  end

  def edit(conn, %{"id" => id}) do
    topic = Notes.get_topic!(id)
    changeset = Notes.change_topic(topic)
    render(conn, "edit.html", topic: topic, changeset: changeset)
  end

  def update(conn, %{"id" => id, "topic" => topic_params}) do
    topic = Notes.get_topic!(id)

    case Notes.update_topic(topic, topic_params) do
      {:ok, topic} ->
        conn
        |> put_flash(:info, "Topic updated successfully.")
        |> redirect(to: topic_path(conn, :show, topic))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", topic: topic, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    topic = Notes.get_topic!(id)
    {:ok, _topic} = Notes.delete_topic(topic)

    conn
    |> put_flash(:info, "Topic deleted successfully.")
    |> redirect(to: topic_path(conn, :index))
  end

  def check_topic_owner(conn, _params) do
    %{params: %{"id" => topic_id}} = conn

    if Repo.get(Topic, topic_id).user_id == conn.assigns.user.id do
      conn
    else 
      conn  
      |> put_flash(:error, "You cannot edit that")
      |> redirect(to: topic_path(conn, :index))
      |> halt()
    end

  end
end
