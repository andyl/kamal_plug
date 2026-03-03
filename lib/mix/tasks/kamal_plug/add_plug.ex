defmodule Mix.Tasks.KamalPlug.AddPlug do
  use Mix.Task
  alias Sourceror.Zipper

  @shortdoc "Idempotently adds plug MyLib.Superplug to Endpoint (if missing)"

  def run(_) do
    app = Mix.Project.config()[:app] |> Atom.to_string()
    endpoint_path = "lib/#{app}_web/endpoint.ex"

    unless File.exists?(endpoint_path) do
      Mix.raise("Endpoint file not found: #{endpoint_path}")
    end

    code = File.read!(endpoint_path)

    zipper =
      code
      |> Sourceror.parse_string!()
      |> Zipper.zip()

    # Find the pipeline — we look for the block that contains plug calls
    # Usually it's the big `quote do ... end` or just sequential plug/2 calls
    new_zipper =
      zipper
      |> Zipper.find(fn
        # Typical pattern in Phoenix.Endpoint
        {{:__block__, _, children}, _} when is_list(children) ->
          Enum.any?(children, &match?({:plug, _, _}, &1))

        _ ->
          false
      end)
      |> case do
        nil ->
          Mix.raise("Could not find plug pipeline block in endpoint.ex")

        zipper ->
          zipper
      end

    # Check if MyLib.Superplug is already present
    already_there? =
      Zipper.find(new_zipper, fn
        {:plug, _, [{:__aliases__, _, [:MyLib, :Superplug]} | _]} -> true
        _ -> false
      end)
      != nil

    if already_there? do
      Mix.shell().info("MyLib.Superplug already present — nothing to do.")
    else
      # Build the AST node we want to insert
      plug_call =
        quote do
          plug MyLib.Superplug
        end
        |> Sourceror.to_string()
        |> Sourceror.parse_string!()

      # Insert before the router plug (most common safe place)
      # or at the end of the pipeline — adjust traversal as needed
      updated =
        new_zipper
        |> Zipper.find(fn
          {:plug, _, [{:__aliases__, _, [:Router]} | _]} -> true
          _ -> false
        end)
        |> case do
          nil ->
            # Fallback: append to end of block
            Zipper.append_child(new_zipper, plug_call)

          router_zipper ->
            Zipper.insert_left(router_zipper, plug_call)
        end
        |> Zipper.root()
        |> Sourceror.to_string()
        |> Code.format_string!(line_length: 98)
        |> IO.iodata_to_binary()

      File.write!(endpoint_path, updated <> "\n")
      Mix.shell().info("Added plug MyLib.Superplug → #{endpoint_path}")
    end
  end
end
