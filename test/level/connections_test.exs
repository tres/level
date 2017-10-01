defmodule Level.ConnectionsTest do
  use Level.DataCase

  alias Level.Connections
  alias Level.Pagination.Result

  describe "users/3" do
    setup do
      insert_signup()
    end

    test "returns edges", %{space: space, user: user} do
      {:ok, %Result{edges: [first_edge | _]}} =
        Connections.users(space, %{first: 1})

      assert first_edge.node.id == user.id
    end

    test "returns total count", %{space: space} do
      {:ok, %Result{total_count: total_count}} =
        Connections.users(space, %{first: 1})

      assert total_count == 1
    end
  end
end