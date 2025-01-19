require "csv"

class BlogImportJob < ApplicationJob
  queue_as :default

  def perform(file_path, user_id)
    user = User.find user_id
    batch_size = 1000
    blogs_batch = []

    CSV.foreach(file_path, headers: true, encoding: "utf8").with_index(2) do |row, line_number|
      blog_data = row.to_h.slice("title", "body").merge("user_id" => user.id)

      if blog_data["title"].present? && blog_data["body"].present?
        blogs_batch << blog_data
      end

      if blogs_batch.size >= batch_size
        Blog.insert_all(blogs_batch)
        blogs_batch.clear
      end
    end

    # Insert remaining records
    Blog.insert_all(blogs_batch) if blogs_batch.any?

    # Delete the file after processing
    File.delete(file_path) if File.exist?(file_path)
  end
end

