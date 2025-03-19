defmodule BeyondStayWeb.Live.HomeLive do
  use BeyondStayWeb, :live_view

  @image_interval 5000 # Auto-scroll interval in milliseconds
  @review_interval 3000 # Auto-scroll interval for reviews in milliseconds

  def mount(_params, _session, socket) do
    images = [
      %{url: "/images/stay1.jpg", description: "Relaxing beachfront stay"},
      %{url: "/images/stay2.jpg", description: "Cozy mountain retreat"},
      %{url: "/images/stay3.jpg", description: "Luxury city escape"}
    ]

    reviews = [
      %{text: "Amazing experience! Highly recommend!", stars: 5},
      %{text: "Loved every moment of our stay.", stars: 4},
      %{text: "Perfect getaway with my pet!", stars: 5},
      %{text: "Great location and friendly staff!", stars: 4},
      %{text: "Would visit again!", stars: 5},
      %{text: "Affordable and comfortable.", stars: 4}
    ]

    if connected?(socket) do
      :timer.send_interval(@image_interval, self(), :next_image)
      :timer.send_interval(@review_interval, self(), :next_review)
    end

    {:ok, assign(socket,
      images: images,
      reviews: reviews,
      current_index: 0,
      current_review: 0,
      transitioning: false
    )}
  end

  def handle_info(:next_image, socket) do
    new_index = rem(socket.assigns.current_index + 1, length(socket.assigns.images))
    {:noreply, assign(socket, current_index: new_index)}
  end

  def handle_info(:next_review, socket) do
    new_index = rem(socket.assigns.current_review + 1, length(socket.assigns.reviews))
    {:noreply, assign(socket, current_review: new_index)}
  end

  def handle_event("prev_image", _params, socket) do
    new_index = if socket.assigns.current_index == 0 do
      length(socket.assigns.images) - 1
    else
      socket.assigns.current_index - 1
    end
    {:noreply, assign(socket, current_index: new_index)}
  end

  def handle_event("next_image", _params, socket) do
    new_index = rem(socket.assigns.current_index + 1, length(socket.assigns.images))
    {:noreply, assign(socket, current_index: new_index)}
  end

  def handle_event("prev_review", _params, socket) do
    new_index = if socket.assigns.current_review == 0 do
      length(socket.assigns.reviews) - 1
    else
      socket.assigns.current_review - 1
    end
    {:noreply, assign(socket, current_review: new_index)}
  end

  def handle_event("next_review", _params, socket) do
    new_index = rem(socket.assigns.current_review + 1, length(socket.assigns.reviews))
    {:noreply, assign(socket, current_review: new_index)}
  end

  def handle_event("set_review", %{"index" => index}, socket) do
    {:noreply, assign(socket, current_review: String.to_integer(index))}
  end

  def render(assigns) do
    ~H"""
    <div class="container mx-auto p-4 bg-background text-dark">
      <header class="text-center text-3xl font-extrabold text-primary py-6">
        Beyond Stay
      </header>

      <!-- Image Carousel -->
      <div class="relative my-6 flex flex-col items-center">
        <div class="relative w-3/5">
          <div class="overflow-hidden rounded-lg shadow-lg">
            <div class="flex transition-all duration-700" style={"transform: translateX(-#{@current_index * 100}%)"}>
              <!-- Add last image at the beginning for infinite loop effect -->
              <div class="w-full flex-shrink-0">
                <img src={List.last(@images).url} alt={List.last(@images).description} class="w-full h-64 object-cover">
              </div>

              <!-- Original images -->
              <%= for image <- @images do %>
                <div class="w-full flex-shrink-0">
                  <img src={image.url} alt={image.description} class="w-full h-64 object-cover">
                </div>
              <% end %>

              <!-- Add first image at the end for infinite loop effect -->
              <div class="w-full flex-shrink-0">
                <img src={List.first(@images).url} alt={List.first(@images).description} class="w-full h-64 object-cover">
              </div>
            </div>
          </div>
        </div>
        <div class="text-center mt-4">
          <h2 class="text-xl font-semibold text-cta">
            <%= Enum.at(@images, rem(@current_index, length(@images))).description %>
          </h2>
        </div>

        <!-- Image Navigation Arrows -->
        <button class="absolute top-1/2 left-0 transform -translate-y-1/2 bg-primary text-light px-4 py-2 rounded-full" phx-click="prev_image">←</button>
        <button class="absolute top-1/2 right-0 transform -translate-y-1/2 bg-primary text-light px-4 py-2 rounded-full" phx-click="next_image">→</button>
      </div>

      <!-- Stay Options Section -->
      <div class="flex flex-col md:flex-row gap-6 my-8">
        <!-- Book a Stay Section -->
        <div class="panel-primary text-center flex-1">
          <h2 class="text-2xl font-bold text-primary">Book a Stay</h2>
          <p class="text-lg mt-4 text-dark">Find the perfect accommodation for your getaway.</p>
          <button class="btn btn-cta mt-4">Book Now</button>
        </div>

        <!-- Book a Pet Stay Section -->
        <div class="panel-accent text-center flex-1">
          <h2 class="text-2xl font-bold text-cta">Book a Pet Stay</h2>
          <p class="text-lg mt-4 text-dark">Because your pets deserve a vacation too!</p>
          <button class="btn btn-primary mt-4">Book Now</button>
        </div>
      </div>

      <!-- Guest Reviews Section -->
      <div class="reviews text-center my-6">
        <h2 class="text-2xl font-bold text-primary mb-4">Guest Reviews</h2>
        <div class="overflow-hidden relative w-full">
          <!-- Review Navigation Arrows -->
          <button class="absolute top-1/2 left-2 transform -translate-y-1/2 bg-primary text-light px-3 py-1 rounded-full z-10" phx-click="prev_review">←</button>
          <button class="absolute top-1/2 right-2 transform -translate-y-1/2 bg-primary text-light px-3 py-1 rounded-full z-10" phx-click="next_review">→</button>

          <div class="review-carousel px-10">
            <div class="review-carousel-inner flex transition-all duration-1000" style={"transform: translateX(-#{@current_review * 50 + 50}%)"}>
              <!-- Add last two reviews at the beginning for infinite loop effect -->
              <%= for review <- Enum.take(Enum.reverse(@reviews), 2) |> Enum.reverse() do %>
                <div class="review-item w-1/2 md:w-1/2 lg:w-1/3 flex-shrink-0 px-2">
                  <div class="card card-primary h-full">
                    <p class="text-lg text-dark italic">"<%= review.text %>"</p>
                    <div class="flex justify-center mt-2">
                      <%= for _ <- 1..review.stars do %>
                        <span class="text-cta text-xl">★</span>
                      <% end %>
                    </div>
                  </div>
                </div>
              <% end %>

              <!-- Original reviews -->
              <%= for review <- @reviews do %>
                <div class="review-item w-1/2 md:w-1/2 lg:w-1/3 flex-shrink-0 px-2">
                  <div class="card card-primary h-full">
                    <p class="text-lg text-dark italic">"<%= review.text %>"</p>
                    <div class="flex justify-center mt-2">
                      <%= for _ <- 1..review.stars do %>
                        <span class="text-cta text-xl">★</span>
                      <% end %>
                    </div>
                  </div>
                </div>
              <% end %>

              <!-- Add first two reviews at the end for infinite loop effect -->
              <%= for review <- Enum.take(@reviews, 2) do %>
                <div class="review-item w-1/2 md:w-1/2 lg:w-1/3 flex-shrink-0 px-2">
                  <div class="card card-primary h-full">
                    <p class="text-lg text-dark italic">"<%= review.text %>"</p>
                    <div class="flex justify-center mt-2">
                      <%= for _ <- 1..review.stars do %>
                        <span class="text-cta text-xl">★</span>
                      <% end %>
                    </div>
                  </div>
                </div>
              <% end %>
            </div>
          </div>
        </div>

        <!-- Review Navigation Dots -->
        <div class="flex justify-center mt-4 gap-2">
          <%= for i <- 0..div(length(@reviews), 2) do %>
            <button
              class={"w-3 h-3 rounded-full transition-all duration-300 #{if rem(div(@current_review, 2), div(length(@reviews), 2) + 1) == i, do: "bg-primary", else: "bg-secondary opacity-50"}"}
              phx-click="set_review"
              phx-value-index={i * 2}
            ></button>
          <% end %>
        </div>
      </div>

      <!-- Footer -->
      <footer class="text-center py-6 bg-primary text-light mt-8 rounded-lg">
        <p class="text-sm">
          Contact Us | Privacy Policy
        </p>
      </footer>
    </div>
    """
  end
end
