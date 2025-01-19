class MemoryLeakJob < ApplicationJob
  queue_as :default
  BATCH_SIZE = 100
  # THROTTLE_LIMIT = 10

  # The purpose of this job to take each blog record and send it to an api and save that api response. 

  def perform
    blogs = Blog.all
    
    blogs.each do |blog|
      validate_and_process(blog)
    end

    Blog.find_each(batch_size: BATCH_SIZE) do |blog|
      process_blog(blog)
      # sleep(1.0 / THROTTLE_LIMIT) # Throttle API calls If the API enforces a limit on the number of requests per second/minute
    end
  end

  private

  def validate_and_process(blog)
    return Rails.logger.info("Invalid blog: #{blog.id}") unless blog_valid?(blog)

    # Make an API request
    blog_to_api(blog)
  end

  def blog_valid?(blog)
    blog.title.present? && blog.body.present?
  end

  def blog_to_api(blog)
    # Mock API call - can be replaced with real HTTP call
    sleep(0.1) # Simulate some network latency
    temp_id = 'blog-id'
    # Save API Response
    api_response_id = temp_id.gsub("id","#{SecureRandom.hex}-#{blog.id}")
    blog.api_responses.create!(
      api_response_id: api_response_id, 
      api_status: ApiResponse.api_statuses.keys.sample
    )
  end
end
