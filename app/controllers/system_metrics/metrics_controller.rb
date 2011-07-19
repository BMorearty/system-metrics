module SystemMetrics
  class MetricsController < ActionController::Base
    def index
      @category_metrics = {}
      categories = SystemMetrics::Metric.select('DISTINCT(category)').order('category ASC').map(&:category)
      categories.each do |category|
        @category_metrics[category] = SystemMetrics::Metric.where(:category => category, :started_at => date_range).order('duration DESC').limit(limit(10))
      end
    end

    def show
      @metric = SystemMetrics::Metric.find(params[:id])
    end

    def destroy
      category = params[:id]
      if category == 'all'
        SystemMetrics::Metric.delete_all
      else
        SystemMetrics::Metric.where(:category => category).delete_all
      end

      redirect_to system_metrics_admin_path
    end

    def category
      @metrics = SystemMetrics::Metric.where(:category => params[:category], :started_at => date_range).order('duration DESC').limit(limit)
    end

    def admin
      @categories = SystemMetrics::Metric.select('category, count(category) as count').order('category ASC').group('category')
    end

    private
      def date_range
        from = params[:from] || '30.minutes'
        from_num, from_unit = from.split('.')
        @from_date = from_num.to_i.send(from_unit.to_sym).ago
        to = params[:to] || '0.minutes'
        to_num, to_unit = to.split('.')
        @to_date = to_num.to_i.send(to_unit.to_sym).ago
        @from_date..@to_date
      end

      def limit(default=100)
        @limit = params[:limit] || default
      end
  end
end
