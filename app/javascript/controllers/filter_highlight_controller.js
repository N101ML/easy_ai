import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["filter", "table"];
  static values = { activeTable: String };

  connect() {
    console.log("filter-hightlight: connected");
    this.updateActiveFilters();
    this.updateTable();
  }

  select(event) {
    const filterElement = event.currentTarget;
    const filterType = filterElement.dataset.filterType;
    const filterValue = filterElement.dataset.filterValue;
    const url = new URL(window.location);

    // Manage query params
    const params = new URLSearchParams(url.search);
    const filterParam = `${filterType}:${filterValue}`;
    const filters = params.getAll("filters[]");

    if (filters.includes(filterParam)) {
      // Remove Filter
      params.delete("filters[]");
      filters
        .filter((f) => f != filterParam)
        .forEach((f) => params.append("filters[]", f));
      filterElement.classList.remove("bg-blue-500", "text-green");
    } else {
      // Add filter
      params.append("filters[]", filterParam);
      filterElement.classList.add("bg-blue-500", "text-green");
    }

    console.log(`params: ${params}`);
    console.log(`url: ${url}`);
    console.log(`url_search: ${url.search}`);
    console.log(`url_search_string: ${params.toString()}`);
    // Update URL without reloading
    url.search = params.toString();
    window.history.replaceState({}, "", url);

    Turbo.visit(url, { action: "replace" });
  }

  updateActiveFilters() {
    const url = new URL(window.location);
    const params = new URLSearchParams(url.search);
    const filters = params.getAll("filters[]");

    this.filterTargets.forEach((filterElement) => {
      const filterType = filterElement.dataset.filterType;
      const filterValue = filterElement.dataset.filterValue;
      const filterParam = `${filterType}:${filterValue}`;

      if (filters.includes(filterParam)) {
        filterElement.classList.add("bg-blue-500", "text-green");
      } else {
        filterElement.classList.remove("bg-blue-500", "text-green");
      }
    });
  }

  updateTable() {
    if (
      this.activeTableValue === "hidden" &&
      this.tableTarget.classList.contains("hidden") == false
    ) {
      this.tableTarget.classList.add("hidden");
    } else {
      this.tableTarget.classList.remove("hidden");
    }
  }

  toggle() {
    this.activeTableValue =
      this.activeTableValue === "hidden" ? "visible" : "hidden";
    this.updateTable();
  }

  reset(event) {
    console.log(`current_target: ${event.currentTarget}`);
    const url = new URL(window.location);
    url.search = "";
    window.history.replaceState({}, "", url);
  }
}
