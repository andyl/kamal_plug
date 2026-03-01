defmodule KamalPlugTest do
  use ExUnit.Case
  doctest KamalPlug

  test "greets the world" do
    assert KamalPlug.hello() == :world
  end
end
