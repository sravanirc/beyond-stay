defmodule BeyondStayWeb.Live.HomeLive do
  use BeyondStayWeb, :live_view

  @image_interval 5000 # Auto-scroll interval in milliseconds

  def mount(_params, _session, socket) do
    images = [
      %{url: "/images/stay1.jpg", description: "Relaxing beachfront stay"},
      %{url: "/images/stay2.jpg", description: "Cozy mountain retreat"},
      %{url: "/images/stay3.jpg", description: "Luxury city escape"}
    ]

    reviews = [
      "Amazing experience! Highly recommend!",
      "Loved every moment of our stay.",
      "Perfect getaway with my pet!"
    ]

    # Start auto-scroll
    if connected?(socket), do: :timer.send_interval(@image_interval, self(), :next_image)

    {:ok, assign(socket, images: images, reviews: reviews, current_index: 0, current_review: 0)}
  end

  def handle_info(:next_image, socket) do
    new_index = rem(socket.assigns.current_index + 1, length(socket.assigns.images))
    {:noreply, assign(socket, current_index: new_index)}
  end

  def handle_event("next_image", _params, socket) do
    new_index = rem(socket.assigns.current_index + 1, length(socket.assigns.images))
    {:noreply, assign(socket, current_index: new_index)}
  end

  def handle_event("next_review", _params, socket) do
    new_index = rem(socket.assigns.current_review + 1, length(socket.assigns.reviews))
    {:noreply, assign(socket, current_review: new_index)}
  end

  def render(assigns) do
    ~H"""
    <div class="container mx-auto p-4 bg-[#F5F5F5] text-[#333333]">
      <header class="text-center text-3xl font-extrabold text-[#146ebb] py-6">
        Beyond Stay
      </header>

      <!-- Carousel with Placeholder Intro -->
      <div class="relative my-6 flex items-center justify-center">
        <div class="relative w-3/5">
          <div class="overflow-hidden rounded-lg shadow-lg">
            <div class="flex transition-all duration-300" style={"transform: translateX(-#{@current_index * 100}%)"}>
              <%= for image <- @images do %>
                <div class="w-full flex-shrink-0 relative">
                  <img src={image.url} alt={image.description} class="w-full h-64 object-cover">
                  <div class="absolute inset-0 bg-black bg-opacity-50 flex items-center justify-center text-white text-lg p-4">
                    <p><%= image.description %></p>
                  </div>
                </div>
              <% end %>
            </div>
          </div>
        </div>
        <div class="w-2/5 p-6 bg-[#146ebb] bg-opacity-50 text-white rounded-lg">
          <h2 class="text-2xl font-bold">Welcome to Beyond Stay</h2>
          <p class="mt-2">Discover your perfect getaway with us, whether it's a cozy retreat, a luxury escape, or a pet-friendly stay.</p>
        </div>
      </div>

      <!-- Book a Stay Buttons -->
      <div class="grid grid-cols-2 gap-6 my-6">
        <div class="p-6 bg-[#63aac0] rounded-lg text-center">
          <h2 class="text-xl font-bold text-white">Book a Stay</h2>
          <button class="bg-[#fbcd40] text-white px-4 py-2 rounded-full shadow-md hover:bg-[#eb6868] transition duration-300">Reserve</button>
        </div>
        <div class="p-6 bg-[#63aac0] rounded-lg text-center">
          <h2 class="text-xl font-bold text-white">Book a Pet Stay</h2>
          <button class="bg-[#fbcd40] text-white px-4 py-2 rounded-full shadow-md hover:bg-[#eb6868] transition duration-300">Reserve</button>
        </div>
      </div>

      <!-- Guest Reviews -->
      <div class="reviews text-center my-6">
        <h2 class="text-2xl font-bold text-[#146ebb] mb-4">Guest Reviews</h2>
        <p class="text-lg text-[#333333] italic"><%= Enum.at(@reviews, @current_review, "No reviews available") %></p>
        <button phx-click="next_review" class="bg-[#04d8fe] text-white px-6 py-3 rounded-full shadow-md hover:bg-[#9859e6] transition duration-300 mt-4">
          Next Review
        </button>
      </div>

      <!-- Footer -->
      <footer class="text-center py-6 bg-[#146ebb] text-white">
        <p class="text-sm">
          Contact Us | Privacy Policy
        </p>
      </footer>
    </div>
    """
  end
end
