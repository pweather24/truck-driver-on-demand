# frozen_string_literal: true

class AddDescriptionToPlans < ActiveRecord::Migration[5.1]
  def change
    add_column :plans, :description, :text
  end
end
