defmodule PetalBoilerplateWeb.PageLive do
  use PetalBoilerplateWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
       modal: false,
       slide_over: false,
       pagination_page: 1
     )}
  end

  @impl true
  def handle_params(params, _uri, socket) do
    case socket.assigns.live_action do
      :index ->
        {:noreply, assign(socket, modal: false, slide_over: false)}

      :modal ->
        {:noreply, assign(socket, modal: params["size"])}

      :slide_over ->
        {:noreply, assign(socket, slide_over: params["origin"])}

      :pagination ->
        {:noreply, assign(socket, pagination_page: String.to_integer(params["page"]))}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="h-screen overflow-auto dark:bg-gray-900">
      <nav class="sticky top-0 flex items-center justify-between w-full h-16 bg-white dark:bg-gray-900">
        <div class="flex ml-3 sm:ml-10">
          <a class="inline-flex hover:opacity-90" href="/">
            <svg
              class="w-24 h-12 sm:w-28"
              viewBox="0 0 1073 352"
              fill="none"
              xmlns="http://www.w3.org/2000/svg"
            >
              <g clip-path="url(#clip0_1_188)">
                <path
                  d="M431.519 325.454C443.241 325.474 455.103 325.494 455.113 319.772L455.228 251.811C464.973 265.922 479.336 272.087 492.594 272.11C528.179 272.17 551.959 238.997 552.029 198.248C552.098 157.36 528.431 124.246 492.845 124.185C478.471 124.161 462.969 131.112 452.757 146.166L452.782 131.234C452.791 125.652 441.767 125.634 430.742 125.615C419.578 125.596 408.554 125.577 408.544 131.159L408.224 319.693C408.214 325.414 419.797 325.434 431.519 325.454ZM478.853 227.848C463.363 227.822 452.64 214.546 452.668 198.079C452.696 181.612 463.464 168.234 478.955 168.26C494.584 168.287 505.307 181.702 505.279 198.169C505.251 214.636 494.483 227.875 478.853 227.848ZM638.285 272.357C657.962 272.391 675.971 268.374 693.293 258.077C694.969 257.243 695.53 255.429 695.534 253.057C695.541 248.731 693.458 242.587 691.096 236.582C688.318 229.042 685.259 222.338 681.212 222.331C680.515 222.33 679.817 222.468 679.118 222.886C668.082 229.566 656.773 232.617 643.795 232.594C629.7 232.571 617.714 224.037 615.782 210.916L697.978 211.056C702.164 211.063 702.314 204.784 702.325 198.504C702.395 157.336 682.774 124.508 639.095 124.434C597.508 124.363 569.405 155.994 569.334 197.58C569.262 239.724 595.722 272.285 638.285 272.357ZM657.692 184.612L615.269 184.54C616.403 174.215 624.795 163.066 639.029 163.09C653.263 163.114 657.432 173.448 657.692 184.612ZM792.349 272.619C808.398 272.646 821.38 270.017 833.673 263.06C835.209 262.226 835.771 260.273 835.775 257.901C835.783 252.877 833.284 245.476 831.339 240.31C828.423 232.071 825.364 225.088 821.178 225.081C820.48 225.08 819.782 225.218 819.084 225.636C812.798 229.253 805.957 231.056 800.235 231.046C791.443 231.031 788.524 224.188 788.536 217.071L788.62 168.089L817.786 168.138C823.786 168.149 823.804 157.961 823.821 147.914C823.838 137.726 823.855 127.679 817.855 127.669L788.688 127.619L788.75 91.3357C788.76 85.6141 777.038 85.5942 765.315 85.5743C753.733 85.5546 741.871 85.5344 741.861 91.256L741.799 127.539L721.285 127.504C715.564 127.495 715.547 137.542 715.529 147.73C715.512 157.777 715.495 167.964 721.216 167.974L741.73 168.009L741.647 216.992C741.587 252.437 758.02 272.561 792.349 272.619ZM883.476 272.774C902.455 272.806 913.911 265.151 922.025 253.442L922.004 265.723C921.995 271.305 932.88 271.323 943.765 271.342C954.51 271.36 965.256 271.378 965.265 265.796L965.412 179.414C965.479 140.061 943.735 124.952 908.428 124.892C889.31 124.86 872.835 129.437 853.559 139.731C851.464 140.844 850.623 142.796 850.619 145.308C850.613 149.215 852.697 154.382 854.921 159.828C858.256 167.928 862.29 175.471 866.337 175.478C866.895 175.479 867.454 175.34 868.013 175.062C882.818 167.272 895.243 164.642 905.988 164.66C914.78 164.675 918.819 169.287 918.808 175.706L918.796 182.684L898.415 186.557C866.727 192.643 844.233 207.956 844.189 234.052C844.144 260.287 861.567 272.737 883.476 272.774ZM901.544 234.01C895.264 233.999 891.084 230.224 891.093 224.921C891.104 218.781 896.135 214.603 902.416 213.637L918.749 210.315L918.734 219.107C918.723 225.805 912.987 234.029 901.544 234.01ZM1039.22 273.039C1047.03 273.052 1055.26 272.368 1063.36 270.708C1068.39 269.739 1068.41 258.715 1068.42 247.83C1068.44 237.643 1068.46 227.595 1063.43 227.586C1063.02 227.586 1062.6 227.585 1062.18 227.724C1059.25 228.556 1056.59 228.831 1054.22 228.827C1048.5 228.817 1046.27 225.324 1046.28 220.58L1046.55 65.8175C1046.55 60.0959 1034.83 60.0759 1023.11 60.056C1011.39 60.0361 999.666 60.0162 999.656 65.7377L999.375 230.827C999.336 253.853 1012.14 272.993 1039.22 273.039Z"
                  class="fill-gray-700 dark:fill-white"
                />
                <path
                  d="M150.218 87.9709C157.627 115.638 155.361 144.148 147.427 158.369C132.763 155.807 102.915 125.568 95.1635 99.6581C89.2007 79.7273 85.1518 40.6847 101.145 27.1285C114.355 30.9225 132.979 39.3591 150.218 87.9709Z"
                  fill="#7C3AED"
                />
                <path
                  d="M78.6045 138.201C109.927 146.052 130.228 160.946 138.817 174.78C129.466 186.363 88.5459 197.802 62.1273 192.016C41.8052 187.566 5.69714 172.173 1.59722 151.613C11.3212 141.9 45.1509 130.694 78.6045 138.201Z"
                  fill="#8C3CE1"
                />
                <path
                  d="M80.7489 218.825C106.03 195.6 130.441 192.123 146.632 193.863C150.009 208.361 133.851 247.658 113.035 264.924C97.0236 278.207 62.6736 297.201 43.9427 287.783C42.2686 274.142 50.859 244.328 80.7489 218.825Z"
                  fill="#9C3ED6"
                />
                <path
                  d="M152.192 279.215C152.725 239.013 156.505 222.968 166.703 210.273C180.733 215.248 205.111 250.048 208.425 276.889C210.975 297.536 208.446 336.706 190.413 347.4C178.022 341.453 152.14 310.034 152.192 279.215Z"
                  fill="#AD40C9"
                />
                <path
                  d="M226.898 260.664C204.934 242.258 197.305 226.345 195.851 213.345C206.633 208.172 240.263 214.001 257.428 227.317C270.632 237.561 291.51 261.191 287.386 277.52C276.979 281.208 246.931 277.451 226.898 260.664Z"
                  fill="#BA42BF"
                />
                <path
                  d="M277.344 215.119C251.989 205.366 242.705 199.212 237.047 189.776C243.486 182.049 271.251 174.749 289.039 178.934C302.722 182.154 326.955 192.931 329.51 206.864C322.839 213.324 303.269 220.84 277.344 215.119Z"
                  fill="#CB44B2"
                />
                <path
                  d="M299.851 164.347C279.962 161.477 272.255 158.563 266.625 152.687C270 146.056 288.826 136.231 302.343 136.328C312.74 136.403 331.989 140.195 336.12 149.825C332.369 155.58 319.489 164.215 299.851 164.347Z"
                  fill="#D445AB"
                />
              </g>
              <defs>
                <clipPath class="text-black fill-black" id="clip0_1_188">
                  <rect width="1072.47" height="352" />
                </clipPath>
              </defs>
            </svg>
          </a>
        </div>

        <div class="flex justify-end gap-3 pr-4">
          <a
            target="_blank"
            class="inline-flex items-center gap-2 p-2 text-gray-500 rounded dark:text-gray-400 dark:hover:text-gray-500 hover:text-gray-400 group"
            href="https://github.com/petalframework/petal_components"
          >
            <svg
              class="w-5 h-5 fill-gray-500"
              xmlns="http://www.w3.org/2000/svg"
              data-name="Layer 1"
              viewBox="0 0 24 24"
            >
              <path d="M12,2.2467A10.00042,10.00042,0,0,0,8.83752,21.73419c.5.08752.6875-.21247.6875-.475,0-.23749-.01251-1.025-.01251-1.86249C7,19.85919,6.35,18.78423,6.15,18.22173A3.636,3.636,0,0,0,5.125,16.8092c-.35-.1875-.85-.65-.01251-.66248A2.00117,2.00117,0,0,1,6.65,17.17169a2.13742,2.13742,0,0,0,2.91248.825A2.10376,2.10376,0,0,1,10.2,16.65923c-2.225-.25-4.55-1.11254-4.55-4.9375a3.89187,3.89187,0,0,1,1.025-2.6875,3.59373,3.59373,0,0,1,.1-2.65s.83747-.26251,2.75,1.025a9.42747,9.42747,0,0,1,5,0c1.91248-1.3,2.75-1.025,2.75-1.025a3.59323,3.59323,0,0,1,.1,2.65,3.869,3.869,0,0,1,1.025,2.6875c0,3.83747-2.33752,4.6875-4.5625,4.9375a2.36814,2.36814,0,0,1,.675,1.85c0,1.33752-.01251,2.41248-.01251,2.75,0,.26251.1875.575.6875.475A10.0053,10.0053,0,0,0,12,2.2467Z" />
            </svg>
            <span class="hidden font-semibold sm:block">
              Star on Github
            </span>
          </a>
          <a
            target="_blank"
            class="inline-flex items-center gap-2 p-2 text-gray-500 rounded dark:text-gray-400 dark:hover:text-gray-500 hover:text-gray-400 group"
            href="https://discord.gg/exbwVbjAct"
          >
            <svg
              class="w-5 h-5 fill-gray-500"
              xmlns="http://www.w3.org/2000/svg"
              data-name="Layer 1"
              viewBox="0 0 16 16"
            >
              <path d="M13.545 2.907a13.227 13.227 0 0 0-3.257-1.011.05.05 0 0 0-.052.025c-.141.25-.297.577-.406.833a12.19 12.19 0 0 0-3.658 0 8.258 8.258 0 0 0-.412-.833.051.051 0 0 0-.052-.025c-1.125.194-2.22.534-3.257 1.011a.041.041 0 0 0-.021.018C.356 6.024-.213 9.047.066 12.032c.001.014.01.028.021.037a13.276 13.276 0 0 0 3.995 2.02.05.05 0 0 0 .056-.019c.308-.42.582-.863.818-1.329a.05.05 0 0 0-.01-.059.051.051 0 0 0-.018-.011 8.875 8.875 0 0 1-1.248-.595.05.05 0 0 1-.02-.066.051.051 0 0 1 .015-.019c.084-.063.168-.129.248-.195a.05.05 0 0 1 .051-.007c2.619 1.196 5.454 1.196 8.041 0a.052.052 0 0 1 .053.007c.08.066.164.132.248.195a.051.051 0 0 1-.004.085 8.254 8.254 0 0 1-1.249.594.05.05 0 0 0-.03.03.052.052 0 0 0 .003.041c.24.465.515.909.817 1.329a.05.05 0 0 0 .056.019 13.235 13.235 0 0 0 4.001-2.02.049.049 0 0 0 .021-.037c.334-3.451-.559-6.449-2.366-9.106a.034.034 0 0 0-.02-.019Zm-8.198 7.307c-.789 0-1.438-.724-1.438-1.612 0-.889.637-1.613 1.438-1.613.807 0 1.45.73 1.438 1.613 0 .888-.637 1.612-1.438 1.612Zm5.316 0c-.788 0-1.438-.724-1.438-1.612 0-.889.637-1.613 1.438-1.613.807 0 1.451.73 1.438 1.613 0 .888-.631 1.612-1.438 1.612Z" />
            </svg>
            <span class="hidden font-semibold sm:block">
              Discussion
            </span>
          </a>
          <a
            target="_blank"
            class="inline-flex items-center gap-2 p-2 text-gray-500 rounded dark:text-gray-400 dark:hover:text-gray-500 hover:text-gray-400 group"
            href="https://twitter.com/PetalFramework"
          >
            <svg
              class="w-5 h-5 fill-gray-500"
              xmlns="http://www.w3.org/2000/svg"
              data-name="Layer 1"
              viewBox="0 0 24 24"
            >
              <path d="M22,5.8a8.49,8.49,0,0,1-2.36.64,4.13,4.13,0,0,0,1.81-2.27,8.21,8.21,0,0,1-2.61,1,4.1,4.1,0,0,0-7,3.74A11.64,11.64,0,0,1,3.39,4.62a4.16,4.16,0,0,0-.55,2.07A4.09,4.09,0,0,0,4.66,10.1,4.05,4.05,0,0,1,2.8,9.59v.05a4.1,4.1,0,0,0,3.3,4A3.93,3.93,0,0,1,5,13.81a4.9,4.9,0,0,1-.77-.07,4.11,4.11,0,0,0,3.83,2.84A8.22,8.22,0,0,1,3,18.34a7.93,7.93,0,0,1-1-.06,11.57,11.57,0,0,0,6.29,1.85A11.59,11.59,0,0,0,20,8.45c0-.17,0-.35,0-.53A8.43,8.43,0,0,0,22,5.8Z" />
            </svg>
            <span class="hidden font-semibold sm:block">
              Follow us
            </span>
          </a>
          <.color_scheme_switch />
        </div>
      </nav>
      <.container class="mt-10 mb-32">
        <.a class="underline dark:text-gray-400" to="/">Back</.a>
        <.h1 class="mt-5" label="Petal Live View JS Components" />

        <.h2 underline class="mt-10" label="Dropdowns" />
        <.h3 label="" />
        <.dropdown label="Dropdown" js_lib="live_view_js">
          <.dropdown_menu_item type="button">
            <HeroiconsV1.Outline.home class="w-5 h-5 text-gray-500 dark:text-gray-300" />
            Button item with icon
          </.dropdown_menu_item>
          <.dropdown_menu_item type="a" href="/" label="a item" />
          <.dropdown_menu_item type="live_patch" href="/" label="Live Patch item" />
          <.dropdown_menu_item type="live_redirect" href="/" label="Live Redirect item" />
        </.dropdown>

        <.h2 underline class="mt-10" label="Modal" />

        <.button label="sm" link_type="live_patch" to={Routes.page_path(@socket, :modal, "sm")} />
        <.button label="md" link_type="live_patch" to={Routes.page_path(@socket, :modal, "md")} />
        <.button label="lg" link_type="live_patch" to={Routes.page_path(@socket, :modal, "lg")} />
        <.button label="xl" link_type="live_patch" to={Routes.page_path(@socket, :modal, "xl")} />
        <.button label="2xl" link_type="live_patch" to={Routes.page_path(@socket, :modal, "2xl")} />
        <.button label="full" link_type="live_patch" to={Routes.page_path(@socket, :modal, "full")} />

        <%= if @modal do %>
          <.modal max_width={@modal} title="Modal">
            <div class="gap-5 text-sm">
              <.form_label label="Add some text here." />
              <div class="flex justify-end">
                <.button label="close" phx-click={PetalComponents.Modal.hide_modal()} />
              </div>
            </div>
          </.modal>
        <% end %>

        <.h2 underline class="mt-10" label="SlideOver" />

        <.button
          label="left"
          link_type="live_patch"
          to={Routes.page_path(@socket, :slide_over, "left")}
        />
        <.button
          label="top"
          link_type="live_patch"
          to={Routes.page_path(@socket, :slide_over, "top")}
        />
        <.button
          label="right"
          link_type="live_patch"
          to={Routes.page_path(@socket, :slide_over, "right")}
        />
        <.button
          label="bottom"
          link_type="live_patch"
          to={Routes.page_path(@socket, :slide_over, "bottom")}
        />

        <%= if @slide_over do %>
          <.slide_over origin={@slide_over} title="SlideOver">
            <div class="gap-5 text-sm">
              <.form_label label="Add some text here." />
              <div class="flex justify-end">
                <.button
                  label="close"
                  phx-click={PetalComponents.SlideOver.hide_slide_over(@slide_over)}
                />
              </div>
            </div>
          </.slide_over>
        <% end %>

        <.h2 underline class="mt-10" label="Interactive Pagination" />
        <.pagination
          link_type="live_patch"
          path="/live/pagination/:page"
          current_page={@pagination_page}
          total_pages={10}
        />

        <.h2 underline class="mt-10" label="Accordion" />
        <.accordion js_lib="live_view_js">
          <:item heading="Accordion">
            <.p>
              Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam quis. Ut enim ad minim veniam quis. Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.
            </.p>
          </:item>
          <:item heading="Accordion 2">
            <.p>
              Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam quis. Ut enim ad minim veniam quis. Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.
            </.p>
          </:item>
          <:item heading="Accordion 3">
            <.p>
              Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam quis. Ut enim ad minim veniam quis. Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.
            </.p>
          </:item>
        </.accordion>
      </.container>
    </div>
    """
  end

  @impl true
  def handle_event("close_modal", _, socket) do
    {:noreply, push_patch(socket, to: "/live")}
  end

  def handle_event("close_slide_over", _, socket) do
    {:noreply, push_patch(socket, to: "/live")}
  end
end
