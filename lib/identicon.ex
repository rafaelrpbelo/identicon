defmodule Identicon do
  @moduledoc """
    Generates a identicon image through a given string
  """

  @doc """
    The main function that it will boostrap all others
  """
  def main(input) do
    input
    |> input_hash
    |> pick_color
    |> build_grid
    |> filter_odd_squares
    |> build_pixel_map
    |> draw_image
  end

  @doc """
    It'll receive an input, convert to md5 hash and to returns a Identicon.Image
    with hex setted

  ## Examples

      iex> Identicon.input_hash("test")
      %Identicon.Image{hex: [9, 143, 107, 205, 70, 33, 211, 115, 202, 222, 78, 131, 38, 39, 180, 246]}

  """
  def input_hash(input) do
    hex = :crypto.hash(:md5, input)
    |> :binary.bin_to_list

    %Identicon.Image{hex: hex}
  end

  @doc """
    Returns an Identicon.Image with color setted as a tuple

  ## Examples

      iex> Identicon.input_hash("test") |> Identicon.pick_color
      %Identicon.Image{hex: [9, 143, 107, 205, 70, 33, 211, 115, 202, 222, 78, 131, 38, 39, 180, 246], color: {9, 143, 107}}

  """
  def pick_color(%Identicon.Image{hex: [r, g, b | _tail]} = image) do
    %Identicon.Image{image | color: {r, g, b}}
  end

  @doc """
    Returns a mirrored row

  ## Examples

      iex> Identicon.mirror_row([1, 2, 3])
      [1, 2, 3, 2, 1]

  """
  def mirror_row([first, second | _tail] = row) do
    row ++ [second, first]
  end

  @doc """
    Returns a Identicon.Image with grid setted.
  """
  def build_grid(%Identicon.Image{hex: hex} = image) do
    grid =
      hex
      |> Enum.chunk(3)
      |> Enum.map(&mirror_row/1)
      |> List.flatten
      |> Enum.with_index

    %Identicon.Image{image | grid: grid}
  end

  @doc """
    Updates the grid from image given to keep only odd squares

  ## Examples

      iex> image = %Identicon.Image{grid: [{11, 1}, {22, 2}, {33, 3}, {44, 4}]}
      iex> Identicon.filter_odd_squares(image)
      %Identicon.Image{grid: [{22, 2}, {44, 4}]}

  """
  def filter_odd_squares(%Identicon.Image{grid: grid} = image) do
    grid = Enum.filter grid, fn({code, _index}) ->
      rem(code, 2) == 0
    end

    %Identicon.Image{image | grid: grid}
  end

  @doc """
    Returns a pixel map by an image

  ## Examples

      iex> %Identicon.Image{grid: grid}
  """
  def build_pixel_map(%Identicon.Image{grid: grid} = image) do
    pixel_map = Enum.map grid, fn({_code, index}) ->
      horizontal = rem(index, 5) * 50
      vertical = div(index, 5) * 50

      top_left = {horizontal, vertical}
      bottom_right = {horizontal + 50, vertical + 50}

      {top_left, bottom_right}
    end

    %Identicon.Image{image | pixel_map: pixel_map}
  end

  def draw_image(%Identicon.Image{pixel_map: pixel_map, color: color}) do
    image = :edg.create(250, 250)
    fill = :edg.fill(color)

    Enum.each pixel_map, fn(start, stop) ->
      :edg.filledRectangle(image, start, stop, fill)
    end

    :edg.render(image)
  end
end
