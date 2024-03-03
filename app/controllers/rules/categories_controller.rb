# frozen_string_literal: true

module Rules
  class CategoriesController < ApplicationController
    before_action :admin_only
    respond_to :html, :json
    respond_to :js, only: %i[reorder]

    def new
      @category = RuleCategory.new
    end

    def edit
      @category = RuleCategory.find(params[:id])
    end

    def create
      @category = RuleCategory.create(category_params)
      notice(@category.errors.any? ? @category.errors.full_messages.join(";") : "Category created")
      respond_with(@category, location: rules_path)
    end

    def update
      @category = RuleCategory.find(params[:id])
      @category.update(category_params)
      notice(@category.errors.any? ? @category.errors.full_messages.join(";") : "Category updated")
      respond_with(@category, location: rules_path)
    end

    def destroy
      @category = RuleCategory.find(params[:id])
      @category.destroy
      notice("Category deleted")
      respond_with(@category, location: rules_path)
    end

    def order
      @categories = RuleCategory.order(:order)
    end

    def reorder
      return render_expected_error(422, "Error: No categories provided") unless params[:_json].is_a?(Array) && params[:_json].any?
      RuleCategory.transaction do
        params[:_json].each do |data|
          rule = RuleCategory.find(data[:id])
          rule.update_attribute(:order, data[:order])
        end

        categories = RuleCategory.all
        if categories.any? { |rule| !rule.valid? }
          errors = []
          categories.each do |rule|
            errors << { id: rule.id, name: rule.name, message: rule.errors.full_messages.join("; ") } if !rule.valid? && rule.errors.any?
          end
          render(json: { success: false, errors: errors }, status: 422)
          raise(ActiveRecord::Rollback)
        else
          respond_to do |format|
            format.json { head(204) }
            format.js do
              render(json: { html: render_to_string(partial: "rules/categories/sort", locals: { categories: RuleCategory.order(:order) }) })
            end
          end
        end
      end
    rescue ActiveRecord::RecordNotFound
      render_expected_error(422, "Error: Category not found")
    end

    private

    def category_params
      params.require(:rule_category).permit(%i[name anchor])
    end
  end
end
