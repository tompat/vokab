require 'rails_helper'

RSpec.describe Item, type: :model do
  describe '#set_next_answer_at_after_answer' do
    subject(:set_next_answer_at_after_answer) { item.set_next_answer_at_after_answer }

    let!(:item) do
      new_item = build(:item, level: level)
      new_item.create_with_reverse
      new_item.reload
    end

    before(:example) do
      item.update_column(:next_answer_at, Time.zone.now)
      item.reverse_item.update_column(:next_answer_at, 10.days.ago)
    end

    let(:level) { 0 }

    context 'when level 0' do
      it { expect{set_next_answer_at_after_answer}.to change{item.next_answer_at.to_date}.to(1.day.from_now.to_date) }
    end

    context 'when level 1' do
      let(:level) { 1 }
      it { expect{set_next_answer_at_after_answer}.to change{item.next_answer_at.to_date}.to(1.day.from_now.to_date) }
    end

    context 'when level 2' do
      let(:level) { 2 }
      it { expect{set_next_answer_at_after_answer}.to change{item.next_answer_at.to_date}.to(7.days.from_now.to_date) }
    end

    context 'when level 3' do
      let(:level) { 3 }
      it { expect{set_next_answer_at_after_answer}.to change{item.next_answer_at.to_date}.to(30.days.from_now.to_date) }
    end

    context 'when level 4' do
      let(:level) { 4 }
      it { expect{set_next_answer_at_after_answer}.to change{item.next_answer_at.to_date}.to(180.days.from_now.to_date) }
    end
  end

  describe '#create_with_reverse' do
    subject(:create_with_reverse) { item.create_with_reverse }

    let(:item) { build(:item) }

    context 'when text_2 is present' do
      it do
        expect(item.next_answer_at).to be(nil)
        expect(item.reverse_item).to be(nil)

        create_with_reverse

        expect(item.next_answer_at.to_date).to eq(Date.today + 1.day)
        expect(item.reverse_item.next_answer_at.to_date).to eq(Date.today + 4.days)
      end
    end
  end

  describe '#to_show_today' do
    subject(:to_show_today) { Item.all.to_show_today }

    context 'when an item was answered 3 days ago' do
      let!(:item_to_include) do
        item = build(:item)
        item.create_with_reverse
        item.update(next_answer_at: 1.day.ago)
        item.reverse_item.update(last_answer_at: 4.days.ago.to_date)
        item
      end

      let!(:item_to_exclude) do
        item = build(:item)
        item.create_with_reverse
        item.update(next_answer_at: 1.day.ago)
        item.reverse_item.update(last_answer_at: 3.days.ago.to_date)
        item
      end

      it { expect(to_show_today.ids).to eq([item_to_include.id]) }
    end

    context 'when there are only level 4 items' do
      let!(:item_level_4_1) { create(:item, level: 4) }
      let!(:item_level_4_2) { create(:item, level: 4) }

      it { expect(to_show_today.ids.sort).to eq([item_level_4_1.id, item_level_4_2.id].sort) }
    end

    context "when there are only level 4 items left for today" do
      let!(:item_level_0_answered) { create(:item, level: 0, next_answer_at: 2.days.from_now) }
      let!(:item_level_4_not_answered) { create(:item, level: 4, next_answer_at: nil, last_answer_at: 5.days.ago) }

      it { expect(to_show_today.ids).to eq([item_level_4_not_answered.id]) }
    end
  end

  describe '#set_level_regarding_answer' do
    subject(:set_level_regarding_answer) { item.set_level_regarding_answer(is_answer_correct) }
    let!(:item) { create(:item, level: level) }
    let(:level) { 0 }

    context 'when answer is not correct' do
      let(:is_answer_correct) { false }
      let(:level) { 4 }

      it { expect{set_level_regarding_answer}.to change{item.level}.from(4).to(0) }
    end

    context 'when level 4 + answer is correct' do
      let(:is_answer_correct) { true }
      let(:level) { 4 }

      it { expect{set_level_regarding_answer}.not_to change{item.level} }
    end
  end

  describe ".to_show_today" do
    subject(:to_show_today) { Item.to_show_today }

    let!(:item_1) { create(:item, next_answer_at: 2.days.ago) }

    context 'with a pending item' do
      context 'when text_2 is nil' do
        let!(:pending_item) { create(:item, text_2: nil) }
        it { expect(subject.ids).to eq([item_1.id]) }
      end

      context 'when text_2 is empty' do
        let!(:pending_item) { create(:item, text_2: "") }
        it { expect(subject.ids).to eq([item_1.id]) }
      end
    end

    context 'with a pending item' do
      let!(:pending_item) { create(:item, text_2: nil) }

      it { expect(subject.ids).to eq([item_1.id]) }
    end

    context 'with an item without next_answer_at' do
      let!(:item_without_next_answer_at) { create(:item, next_answer_at: nil) }

      it { expect(subject.ids.sort).to eq([item_1.id, item_without_next_answer_at.id].sort) }
    end

    context "when reverse items are excluded because of the future answers of their items" do
      let!(:item_1) do
        item = build(:item)
        item.create_with_reverse
        item.update(next_answer_at: 1.day.ago)
        item.reverse_item.update(next_answer_at: 1.day.ago, last_answer_at: 5.days.ago)
        item
      end

      let!(:item_2) do
        item = build(:item, next_answer_at: 1.day.ago)
        item.create_with_reverse
        item.update(next_answer_at: 1.day.ago)
        item.reverse_item.update(next_answer_at: 1.day.ago, last_answer_at: 5.days.ago)
        item
      end

      it { expect(subject.ids.sort).to eq([item_1.id, item_2.id].sort) }
    end
  end

  describe '#update' do
    subject(:update) { item.update(params) }
    context 'when setting text_2 for the first time' do
      let(:item) { create(:item, text_2: nil) }
      let(:params) { { text_2: "some text" } }

      it { expect{update}.to change{item.reverse_item}.from(nil) }
    end
  end

  describe '.counts_by_level' do
    subject(:counts_by_level) { items.counts_by_level }

    context 'with only items waiting answer' do
      let(:items) { Item.all.waiting_answer }

      let!(:level_0_waiting_answer_1) { create(:item, level: 0, next_answer_at: nil) }
      let!(:level_0_waiting_answer_2) { create(:item, level: 0, next_answer_at: 1.day.ago) }
      let!(:level_0_not_waiting_answer) { create(:item, level: 0, next_answer_at: 1.day.from_now) }
      let!(:level_1_not_waiting_answer) { create(:item, level: 1, next_answer_at: 1.day.from_now) }
      let!(:level_2_waiting_answer_1) { create(:item, level: 2, next_answer_at: nil) }
      let!(:level_2_not_waiting_answer) { create(:item, level: 2, next_answer_at: 1.day.from_now) }
      let!(:level_3_waiting_answer_1) { create(:item, level: 3, next_answer_at: nil) }
      let!(:level_3_waiting_answer_2) { create(:item, level: 3, next_answer_at: 1.day.ago) }
      let!(:level_3_waiting_answer_3) { create(:item, level: 3, next_answer_at: 3.day.ago) }
      let!(:level_3_not_waiting_answer) { create(:item, level: 3, next_answer_at: 1.day.from_now) }

      it { expect(counts_by_level).to eq({ 0 => 2, 1 => 0, 2 => 1, 3 => 3, 4 => 0}) }
    end

    context 'with all items' do
      let(:items) { Item.all }

      let!(:level_0_1) { create(:item, level: 0, next_answer_at: nil) }
      let!(:level_0_2) { create(:item, level: 0, next_answer_at: 1.day.from_now) }
      let!(:level_1_1) { create(:item, level: 1, next_answer_at: 1.day.from_now) }
      let!(:level_3_1) { create(:item, level: 3, next_answer_at: nil) }
      let!(:level_3_2) { create(:item, level: 3, next_answer_at: 1.day.from_now) }
      let!(:level_3_3) { create(:item, level: 3, next_answer_at: 1.day.ago) }

      it { expect(counts_by_level).to eq({ 0 => 2, 1 => 1, 2 => 0, 3 => 3, 4 => 0}) }
    end
  end

  describe '.waiting_answer' do
    subject(:waiting_answer) { items.waiting_answer }

    let(:items) { Item.all.waiting_answer }

    let!(:waiting_answer_1) { create(:item, level: 0, next_answer_at: nil) }
    let!(:waiting_answer_2) { create(:item, level: 0, next_answer_at: 1.day.ago) }
    let!(:not_waiting_answer_1) { create(:item, level: 0, next_answer_at: 1.day.from_now) }
    let!(:not_waiting_answer_2) { create(:item, level: 0, next_answer_at: 1.day.ago, text_2: "") }

    let!(:not_waiting_answer_3) do
      item = build(:item)
      item.create_with_reverse
      item.update(next_answer_at: 1.day.ago)
      item.reverse_item.update(last_answer_at: 3.days.ago.to_date)
      item
    end

    it { expect(waiting_answer.ids).to match_array([waiting_answer_1.id, waiting_answer_2.id]) }
  end

  describe ".next" do
    subject { Item.all.next }

    context 'when there are level 4 items and other levels items' do
      let!(:item_level_0) { create(:item, level: 0, next_answer_at: nil, last_answer_at: 3.days.ago) }
      let!(:item_level_1) { create(:item, level: 1, next_answer_at: nil, last_answer_at: 4.days.ago) }
      let!(:item_level_2) { create(:item, level: 2, next_answer_at: nil, last_answer_at: 2.days.ago) }
      let!(:item_level_3) { create(:item, level: 3, next_answer_at: nil, last_answer_at: 1.days.ago) }
      let!(:item_level_4) { create(:item, level: 4, next_answer_at: nil, last_answer_at: 10.days.ago) }

      it { expect(subject.id).to eq(item_level_1.id) }
    end
  end

  describe "#shift" do
    subject(:shift) { item.shift }

    let!(:item) { create(:item, last_answer_at: nil, next_answer_at: Date.today) }

    it do
      expect{shift}
        .to change{item.last_answer_at}.to(Date.today)
        .and change{item.next_answer_at}.to(Date.today + 3.days)
    end
  end
end
