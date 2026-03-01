defmodule KamalPlug.HealthCheckTest do
  use ExUnit.Case

  alias KamalPlug.HealthCheck

  test "returns 200 ok for /up" do
    conn =
      :get
      |> Plug.Test.conn("/up")
      |> HealthCheck.call(HealthCheck.init([]))

    assert conn.status == 200
    assert conn.resp_body == "ok"
    assert conn.halted
  end

  test "passes through other requests" do
    conn =
      :get
      |> Plug.Test.conn("/other")
      |> HealthCheck.call(HealthCheck.init([]))

    refute conn.halted
  end
end
