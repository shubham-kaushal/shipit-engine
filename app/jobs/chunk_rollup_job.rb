class ChunkRollupJob < BackgroundJob
  @queue = :default

  extend BackgroundJob::DeployExclusive

  def perform(params)
    @task = Task.find(params[:task_id])

    unless @task.finished?
      logger.error("Task ##{@task.id} is not finished (current state: #{@task.status}). Aborting.")
      return
    end

    chunk_count = @task.chunks.count

    unless chunk_count > 1
      logger.error("Task ##{@task.id} only has #{chunk_count} chunks. Aborting.")
      return
    end

    output = @task.chunk_output

    ActiveRecord::Base.transaction do
      @task.chunks.delete_all
      @task.write(output)
      @task.update_attribute(:rolled_up, true)
    end
  end
end
