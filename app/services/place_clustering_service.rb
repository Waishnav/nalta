require 'kmeans-clusterer'

class PlaceClusteringService
  def initialize(places, num_days)
    @places = places
    @num_days = num_days
  end

  def cluster
    return @places.in_groups(@num_days, false) if @places.size <= @num_days

    data = @places.map { |place| [place.latitude, place.longitude] }
    k = [@num_days, @places.size].min
    kmeans = KMeansClusterer.run k, data, labels: @places, runs: 50

    clusters = kmeans.clusters.map(&:points)


    # Rebalance clusters
    rebalance_clusters(clusters)
    clusters.sort_by!(&:size).reverse!
    clusters.map { |cluster| cluster.map(&:label) }
  end

  private

  def rebalance_clusters(clusters)
    avg_size = @places.size.to_f / @num_days
    clusters.sort_by!(&:size)

    while clusters.first && clusters.first.size < avg_size * 0.5 && clusters.last && clusters.last.size > avg_size * 1.5
      item = clusters.last.pop
      clusters.first << item unless clusters.first.nil?
      clusters.sort_by!(&:size)
    end

    # If we have more clusters than days, merge the smallest clusters
    while clusters.size > @num_days
      smallest = clusters.shift
      closest = find_closest_cluster(smallest, clusters)
      closest.concat(smallest) if closest
    end

    clusters
  end

  def find_closest_cluster(cluster, other_clusters)
    center = cluster_center(cluster)
    other_clusters.min_by do |other|
      other_center = cluster_center(other)
      distance(center, other_center)
    end
  end

  def cluster_center(cluster)
    lat_sum = lng_sum = 0
    cluster.each do |place|
      lat_sum += place.latitude
      lng_sum += place.longitude
    end
    [lat_sum / cluster.size, lng_sum / cluster.size]
  end

  def distance(point1, point2)
    # euclidean distance
    Math.sqrt((point1[0] - point2[0])**2 + (point1[1] - point2[1])**2)
  end
end
