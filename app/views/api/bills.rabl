object false

child (@bills => :bills) {
  extends "bill/show"
}

code(:total_pages) { @bills.total_pages }

# i{:simple => {:except => [:rolls, :hot_bill_category_id]},
