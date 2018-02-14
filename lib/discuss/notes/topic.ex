defmodule Discuss.Notes.Topic do
  use Ecto.Schema
  import Ecto.Changeset
  alias Discuss.Notes.Topic

  schema "topics" do
    field :title, :string
    belongs_to :user,  Discuss.Notes.User
    has_many :comments, Discuss.Notes.Comment
    timestamps()
  end

  @doc """
    topic - represent the model in the database
    attrs - represents the params passed from the request.
    cast - merge the struct and the parameters data
    validate_requried - validation
  """
  def changeset(%Topic{} = topic, attrs) do
    topic
    |> cast(attrs, [:title])
    |> validate_required([:title])
  end
end
