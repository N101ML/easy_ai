import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["filter"];
  selectedFilters = new Map();

  connect() {
    const url = new URL(window.location.href);
    this.filterTargets.forEach((filter) => {
      const filterValue = filter.dataset.filterValue;
      const filterType = filter.dataset.filterType;

      if (url.searchParams.getAll(`${filterType}[]`).includes(filterValue)) {
        filter.classList.add("bg-blue-500", "text-green");
        this.addToSelectedFilters(filterType, filterValue);
      }
    });
  }

  select(event) {
    const filter = event.currentTarget;
    const filterValue = filter.dataset.filterValue;
    const filterType = filter.dataset.filterType;

    filter.classList.toggle("bg-blue-500");
    filter.classList.toggle("text-green");
    this.toggleSelectedFilter(filterType, filterValue);

    this.updateUrl();
  }

  toggleSelectedFilter(filterType, filterValue) {
    if (this.selectedFilters.has(filterType)) {
      const values = this.selectedFilters.get(filterType);
      values.has(filterValue)
        ? values.delete(filterValue)
        : values.add(filterValue);
    } else {
      this.selectedFilters.set(filterType, new Set([filterValue]));
    }
  }

  addToSelectedFilters(filterType, filterValue) {
    if (!this.selectedFilters.has(filterType)) {
      this.selectedFilters.set(filterType, new Set());
    }
    this.selectedFilters.get(filterType).add(filterValue);
  }

  updateUrl() {
    const url = new URL(window.location.href);

    this.selectedFilters.forEach((values, type) => {
      url.searchParams.delete(`${type}[]`);
    });

    this.selectedFilters.forEach((values, type) => {
      values.forEach((value) => {
        url.searchParams.append(`${type}[]`, value);
      });
    });

    Turbo.visit(url, { action: "replace" });
  }

  reset() {
    this.filterTargets.forEach((filter) => {
      filter.classList.remove("bg-blue-500", "text-green");
    });
    this.selectedFilters.clear();

    const url = new URL(window.location.href);
    url.searchParams.clear();
    Turbo.visi(url, { action: "replace" });
  }
}
