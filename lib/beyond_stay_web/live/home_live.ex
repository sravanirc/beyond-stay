defmodule BeyondStayWeb.Live.HomeLive do
  use BeyondStayWeb, :live_view

  # Auto-scroll interval in milliseconds
  @image_interval 5000
  # Auto-scroll interval for reviews in milliseconds
  @review_interval 3000

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

    {:ok,
     assign(socket,
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
    new_index =
      if socket.assigns.current_index == 0 do
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
    new_index =
      if socket.assigns.current_review == 0 do
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
            <div
              class="flex transition-all duration-700"
              style={"transform: translateX(-#{@current_index * 100}%)"}
            >
              <!-- Add last image at the beginning for infinite loop effect -->
              <div class="w-full flex-shrink-0">
                <img
                  src={List.last(@images).url}
                  alt={List.last(@images).description}
                  class="w-full h-64 object-cover"
                />
              </div>
              
    <!-- Original images -->
              <%= for image <- @images do %>
                <div class="w-full flex-shrink-0">
                  <img src={image.url} alt={image.description} class="w-full h-64 object-cover" />
                </div>
              <% end %>
              
    <!-- Add first image at the end for infinite loop effect -->
              <div class="w-full flex-shrink-0">
                <img
                  src={List.first(@images).url}
                  alt={List.first(@images).description}
                  class="w-full h-64 object-cover"
                />
              </div>
            </div>
          </div>
        </div>
        
        <div class="text-center mt-4">
          <h2 class="text-xl font-semibold text-cta">
            {Enum.at(@images, rem(@current_index, length(@images))).description}
          </h2>
        </div>
        
    <!-- Image Navigation Arrows -->
        <button
          class="absolute top-1/2 left-0 transform -translate-y-1/2 bg-primary text-light px-4 py-2 rounded-full"
          phx-click="prev_image"
        >
          ←
        </button>
        <button
          class="absolute top-1/2 right-0 transform -translate-y-1/2 bg-primary text-light px-4 py-2 rounded-full"
          phx-click="next_image"
        >
          →
        </button>
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
      
      <div class="external-profiles text-center my-12 bg-gradient-to-r from-blue-50 to-purple-50 py-10 px-6 rounded-xl shadow-lg border-2 border-primary">
        <h2 class="text-3xl font-extrabold text-primary mb-4 tracking-tight">
          Our Verified Profiles
        </h2>
        
        <div class="w-24 h-1 bg-cta mx-auto mb-6 rounded-full"></div>
        
        <p class="text-xl mb-8 max-w-2xl mx-auto font-medium">
          We're proud of our reputation! Check out our verified profiles and reviews on these trusted platforms:
        </p>
        
        <div class="flex flex-col md:flex-row justify-center gap-8 max-w-3xl mx-auto">
          <!-- Airbnb Profile Card -->
          <div class="bg-white rounded-xl shadow-xl overflow-hidden transform transition-all duration-300 hover:scale-105 flex-1 max-w-md border-t-4 border-[#FF5A5F]">
            <div class="p-6">
              <div class="w-16 h-16 mx-auto mb-4">
                <svg
                  viewBox="0 0 24 24"
                  xmlns="http://www.w3.org/2000/svg"
                  class="text-[#FF5A5F] w-full h-full"
                >
                  <path
                    fill="currentColor"
                    d="M12.0002 0C5.37358 0 0 5.37358 0 12.0002C0 18.6268 5.37358 24 12.0002 24C18.6268 24 24 18.6268 24 12.0002C24 5.37358 18.6268 0 12.0002 0ZM12.0002 1.50005C17.7993 1.50005 22.5 6.20069 22.5 12.0002C22.5 17.7993 17.7993 22.5 12.0002 22.5C6.20069 22.5 1.50005 17.7993 1.50005 12.0002C1.50005 6.20069 6.20069 1.50005 12.0002 1.50005ZM15.2763 9.97049C15.2763 11.1151 14.7857 12.1529 13.9531 12.8511C13.0266 13.6241 11.8225 14.0551 10.5589 14.0551C9.29533 14.0551 8.09118 13.6241 7.16472 12.8511C6.33212 12.1529 5.84155 11.1151 5.84155 9.97049C5.84155 8.82589 6.33212 7.78809 7.16472 7.08984C8.09118 6.31689 9.29533 5.88589 10.5589 5.88589C11.8225 5.88589 13.0266 6.31689 13.9531 7.08984C14.7857 7.78809 15.2763 8.82589 15.2763 9.97049ZM18.1584 9.97049C18.1584 12.2646 16.8948 14.3402 14.9636 15.6038C13.0324 16.8674 10.5589 17.2984 8.21484 16.8674C5.87079 16.4364 3.95959 15.1728 2.91064 13.2416C1.86169 11.3104 1.86169 9.05469 2.91064 7.12349C3.95959 5.19229 5.87079 3.92869 8.21484 3.49769C10.5589 3.06669 13.0324 3.49769 14.9636 4.76129C16.8948 6.02489 18.1584 8.10049 18.1584 10.3946V9.97049Z"
                  />
                </svg>
              </div>
              
              <h3 class="text-2xl font-bold text-gray-800 mb-3">Airbnb Profile</h3>
              
              <p class="text-gray-600 mb-6">
                See our 5-star accommodations and read what guests have to say about their stays with us.
              </p>
              
              <a
                href="https://www.airbnb.com/users/show/675715439"
                target="_blank"
                rel="noopener noreferrer"
                class="inline-flex items-center justify-center w-full px-6 py-4 bg-[#FF5A5F] text-white text-lg font-bold rounded-lg shadow-md hover:bg-[#FF4347] transition-all"
              >
                <span class="mr-2">View Airbnb Profile</span>
                <svg
                  xmlns="http://www.w3.org/2000/svg"
                  class="h-5 w-5"
                  viewBox="0 0 20 20"
                  fill="currentColor"
                >
                  <path
                    fill-rule="evenodd"
                    d="M10.293 5.293a1 1 0 011.414 0l4 4a1 1 0 010 1.414l-4 4a1 1 0 01-1.414-1.414L12.586 11H5a1 1 0 110-2h7.586l-2.293-2.293a1 1 0 010-1.414z"
                    clip-rule="evenodd"
                  />
                </svg>
              </a>
            </div>
          </div>
          
    <!-- Rover Profile Card -->
          <div class="bg-white rounded-xl shadow-xl overflow-hidden transform transition-all duration-300 hover:scale-105 flex-1 max-w-md border-t-4 border-[#7B68EE]">
            <div class="p-6">
              <div class="w-16 h-16 mx-auto mb-4">
                <svg
                  viewBox="0 0 24 24"
                  xmlns="http://www.w3.org/2000/svg"
                  class="text-[#7B68EE] w-full h-full"
                >
                  <path
                    fill="currentColor"
                    d="M12 2C6.48 2 2 6.48 2 12C2 17.52 6.48 22 12 22C17.52 22 22 17.52 22 12C22 6.48 17.52 2 12 2ZM12 4C16.42 4 20 7.58 20 12C20 16.42 16.42 20 12 20C7.58 20 4 16.42 4 12C4 7.58 7.58 4 12 4ZM16.5 13C16.5 14.38 15.38 15.5 14 15.5C12.62 15.5 11.5 14.38 11.5 13C11.5 11.62 12.62 10.5 14 10.5C15.38 10.5 16.5 11.62 16.5 13ZM7.5 13C7.5 11.62 8.62 10.5 10 10.5C10.76 10.5 11.42 10.88 11.83 11.44C11.33 12.14 11 13.04 11 14C11 14.96 11.33 15.86 11.83 16.56C11.42 17.12 10.76 17.5 10 17.5C8.62 17.5 7.5 16.38 7.5 15V13Z"
                  />
                </svg>
              </div>
              
              <h3 class="text-2xl font-bold text-gray-800 mb-3">Rover Pet Sitting</h3>
              
              <p class="text-gray-600 mb-6">
                Discover our pet-friendly accommodations and see why pet owners trust us with their furry friends.
              </p>
              
              <a
                href="https://www.rover.com/members/sabrina-s-pet-friendly-home-with-garden/"
                target="_blank"
                rel="noopener noreferrer"
                class="inline-flex items-center justify-center w-full px-6 py-4 bg-[#7B68EE] text-white text-lg font-bold rounded-lg shadow-md hover:bg-[#6A5ACD] transition-all"
              >
                <span class="mr-2">View Rover Profile</span>
                <svg
                  xmlns="http://www.w3.org/2000/svg"
                  class="h-5 w-5"
                  viewBox="0 0 20 20"
                  fill="currentColor"
                >
                  <path
                    fill-rule="evenodd"
                    d="M10.293 5.293a1 1 0 011.414 0l4 4a1 1 0 010 1.414l-4 4a1 1 0 01-1.414-1.414L12.586 11H5a1 1 0 110-2h7.586l-2.293-2.293a1 1 0 010-1.414z"
                    clip-rule="evenodd"
                  />
                </svg>
              </a>
            </div>
          </div>
        </div>
        
    <!-- Trust Badges -->
        <div class="mt-10 flex flex-wrap justify-center gap-4">
          <div class="bg-white px-4 py-2 rounded-full shadow-md flex items-center">
            <svg
              xmlns="http://www.w3.org/2000/svg"
              class="h-5 w-5 text-green-500 mr-2"
              viewBox="0 0 20 20"
              fill="currentColor"
            >
              <path
                fill-rule="evenodd"
                d="M6.267 3.455a3.066 3.066 0 001.745-.723 3.066 3.066 0 013.976 0 3.066 3.066 0 001.745.723 3.066 3.066 0 012.812 2.812c.051.643.304 1.254.723 1.745a3.066 3.066 0 010 3.976 3.066 3.066 0 00-.723 1.745 3.066 3.066 0 01-2.812 2.812 3.066 3.066 0 00-1.745.723 3.066 3.066 0 01-3.976 0 3.066 3.066 0 00-1.745-.723 3.066 3.066 0 01-2.812-2.812 3.066 3.066 0 00-.723-1.745 3.066 3.066 0 010-3.976 3.066 3.066 0 00.723-1.745 3.066 3.066 0 012.812-2.812zm7.44 5.252a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z"
                clip-rule="evenodd"
              />
            </svg>
             <span class="font-medium">Verified Host</span>
          </div>
          
          <div class="bg-white px-4 py-2 rounded-full shadow-md flex items-center">
            <svg
              xmlns="http://www.w3.org/2000/svg"
              class="h-5 w-5 text-yellow-500 mr-2"
              viewBox="0 0 20 20"
              fill="currentColor"
            >
              <path d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 00.95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 00-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.54 1.118l-2.8-2.034a1 1 0 00-1.175 0l-2.8 2.034c-.784.57-1.838-.197-1.539-1.118l1.07-3.292a1 1 0 00-.364-1.118L2.98 8.72c-.783-.57-.38-1.81.588-1.81h3.461a1 1 0 00.951-.69l1.07-3.292z" />
            </svg>
             <span class="font-medium">5-Star Rated</span>
          </div>
          
          <div class="bg-white px-4 py-2 rounded-full shadow-md flex items-center">
            <svg
              xmlns="http://www.w3.org/2000/svg"
              class="h-5 w-5 text-blue-500 mr-2"
              viewBox="0 0 20 20"
              fill="currentColor"
            >
              <path
                fill-rule="evenodd"
                d="M2.166 4.999A11.954 11.954 0 0010 1.944 11.954 11.954 0 0017.834 5c.11.65.166 1.32.166 2.001 0 5.225-3.34 9.67-8 11.317C5.34 16.67 2 12.225 2 7c0-.682.057-1.35.166-2.001zm11.541 3.708a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z"
                clip-rule="evenodd"
              />
            </svg>
             <span class="font-medium">Trusted by Guests</span>
          </div>
          
          <div class="bg-white px-4 py-2 rounded-full shadow-md flex items-center">
            <svg
              xmlns="http://www.w3.org/2000/svg"
              class="h-5 w-5 text-red-500 mr-2"
              viewBox="0 0 20 20"
              fill="currentColor"
            >
              <path
                fill-rule="evenodd"
                d="M3.172 5.172a4 4 0 015.656 0L10 6.343l1.172-1.171a4 4 0 115.656 5.656L10 17.657l-6.828-6.829a4 4 0 010-5.656z"
                clip-rule="evenodd"
              />
            </svg>
             <span class="font-medium">Pet Friendly</span>
          </div>
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
