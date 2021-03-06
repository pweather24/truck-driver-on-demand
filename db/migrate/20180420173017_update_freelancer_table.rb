# frozen_string_literal: true

class UpdateFreelancerTable < ActiveRecord::Migration[5.1]
  def change
    change_column :freelancers, :name, :string, null: true
    add_column :freelancers, :registration_step, :string
  end
end
