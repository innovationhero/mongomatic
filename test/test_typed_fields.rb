require 'helper'
require 'minitest/autorun'

class TestTypedFields < MiniTest::Unit::TestCase
  def setup
    Rig.collection.drop
  end

  def test_reader_method_generation
    r = Rig.new(:age => 26)
    assert_equal r.age, 26
  end

  def test_writer_method_generation
    r = Rig.new
    r.age = 26
    assert_equal r.age, 26
  end

  def test_raising_error_on_invalid_type
    r = Rig.new
    assert r["manufacturer"].blank?
    r["manufacturer"] = { "phone" => 123 }
    assert_raises(Mongomatic::TypedFields::InvalidType) { r.valid? }
    r["manufacturer"] = {}
    r["manufacturer"]["phone"] = "(800) 123 456 789"
    assert_equal true, r.valid?
    assert_equal "(800) 123 456 789", r["manufacturer"]["phone"]
  end

  def test_cast_string
    r = Rig.new
    r["manufacturer"] = {}
    r["manufacturer"]["name"] = ["Wings","Parachuting","Company"]
    assert_equal ["Wings","Parachuting","Company"], r["manufacturer"]["name"]
    assert r.valid?
    assert_equal ["Wings","Parachuting","Company"].to_s, r["manufacturer"]["name"]
  end

  def test_cast_number
    r = Rig.new
    r["age"] = "4"
    assert_equal "4", r["age"]
    assert r.valid?
    assert_equal 4, r["age"]
  end

  def test_cast_float
    r = Rig.new
    r["waist_measurement"] = "34.3"
    assert_equal "34.3", r["waist_measurement"]
    assert r.valid?
    assert_equal 34.3, r["waist_measurement"]
  end

  def test_cast_object_id
    r = Rig.new
    assert r.insert
    r2 = Rig.new
    r2["friends_rig_id"] = r["_id"].to_s
    r2.insert
    assert_equal "BSON::ObjectId", r2["friends_rig_id"].class.to_s
  end
end
