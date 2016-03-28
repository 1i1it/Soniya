$categories = $mongo.collection('categories')

def get_all_categories
  $categories.find_all
end