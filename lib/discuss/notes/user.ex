defmodule Discuss.Notes.User do
    use Ecto.Schema
    import Ecto.Changeset
    alias Discuss.Notes.User

    @derive {Poison.Encoder, only: [:email]}

    schema "users" do
        field :email, :string
        field :provider, :string
        field :token, :string
        has_many :topics, Discuss.Notes.Topic
        has_many :comments, Discuss.Notes.Comment

        timestamps()
    end

    def changeset(struct, params \\ %{}) do
        struct
        |> cast(params, [:email, :provider, :token] )
        |> validate_required([:email, :provider, :token])
    end
end