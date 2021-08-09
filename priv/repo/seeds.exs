# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     RealworldPhoenix.Repo.insert!(%RealworldPhoenix.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias RealworldPhoenix.Repo
alias RealworldPhoenix.Articles.Article
alias RealworldPhoenix.Accounts.User

user = %User{
  email: "hoge@example.com",
  username: "username",
  password: "password"
}

changeset =
  User.changeset(%User{}, %{email: "hoge@xample.com", username: "username", password: "password"})

Repo.insert!(changeset)

1..10
|> Enum.each(fn i ->
  article = %Article{
    slug: "how-to-train-your-dragon-#{i}",
    title: "How to train your dragon #{i}",
    description: "Ever wonder how?",
    body: "It takes a Jacobian",
    tagList: ["dragons", "training"],
    favoritesCount: 0,
    author_id: user.id
  }

  Repo.insert!(article)
end)
