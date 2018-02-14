defmodule Discuss.Notes.Comment do
    use Ecto.Schema
    import Ecto.Changeset    
    alias Discuss.Notes.Comment

    @derive {Poison.Encoder, only: [:content, :user]}

    schema "comments" do
        field :content, :string
        belongs_to :user, Discuss.Notes.User
        belongs_to :topic, Discuss.Notes.Topic

        timestamps()
    end

    def changeset(struct, params \\ %{}) do
        struct
        |> cast(params, [:content])
        |> validate_required([:content])

    end
end