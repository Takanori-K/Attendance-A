class Attendance < ApplicationRecord
  belongs_to :user
  
  validates :worked_on, presence: true
  validates :note, length: { maximum: 50 }
  validates :edit_note, length: { maximum: 50 }
  #validates_acceptance_of :agreement, allow_nil: false, on: :update

  
  validate :finished_at_is_invalid_without_a_started_at
  validate :started_at_than_finished_at_fast_if_invalid
  #validate :applying_started_at_is_invalid_without_a_applying_finished_at
  #validate :applying_finished_at_is_invalid_without_a_applying_started_at
  #validate :applying_started_at_than_applying_finished_at_fast_if_invalid
  #validate :overtime_change?
  #validate :month_request_change?
  #validate :worked_request_change?
  #validate :month_change_request_sign
  validate :worked_request_sign_and_started_at_than_finished_at_fast_if_invalid
  validate :worked_request_sign_and_finished_at_is_invalid_without_a_started_at
  validate :worked_request_sign_and_started_at_is_invalid_without_a_finished_at
  
  enum overtime_status: { applying: 0, approval: 1, denial: 2 }
  enum month_status: { month_applying: 0, month_approval: 1, month_denial: 2 }
  enum worked_status: { worked_applying: 0, worked_approval: 1, worked_denial: 2 }
  
  def finished_at_is_invalid_without_a_started_at
    errors.add(:started_at,"が必要です。") if started_at.blank? && finished_at.present?
  end
  
  def started_at_than_finished_at_fast_if_invalid
    if started_at.present? && finished_at.present? && tomorrow.present? && tomorrow == "false"
      errors.add(:started_at, "より早い時間は無効です。") if started_at > finished_at
    end
  end
  
  #編集時間
  def applying_started_at_is_invalid_without_a_applying_finished_at
    errors.add(:applying_finished_at,"が必要です。") if applying_finished_at.blank? && applying_started_at.present? && worked_request_sign.present?
  end
  
  #編集時間
  def applying_finished_at_is_invalid_without_a_applying_started_at
    if worked_request_sign.present?
      errors.add(:applying_started_at,"が必要です。") if applying_started_at.blank? && applying_finished_at.blank?
    end  
  end
  
  #編集時間
  def applying_started_at_than_applying_finished_at_fast_if_invalid
    if applying_started_at.present? && applying_finished_at.present? && next_day.present? && next_day == "false" && worked_request_sign.present?
      errors.add(:applying_started_at, "より早い時間は無効です。") if applying_started_at > applying_finished_at
    end
  end
  
  def overtime_change?
    if overtime_change.present? && overtime_change == "0"
      errors.add(:overtime_change, "チェックを入れてください。")
    end
  end
  
  def month_request_change?
    if month_change.present? && month_change == "0"
      errors.add(:month_change, "チェックを入れてください。")
    end
  end
  
  def month_change_request_sign
    errors.add(:one_month_sign, "所属長を選択してください。") if one_month_sign.blank?
  end
  
  def worked_request_change?
    if worked_change.present? && worked_change == "0"
      errors.add(:worked_change, "チェックを入れてください。")
    end
  end
  
  def worked_request_sign_and_started_at_than_finished_at_fast_if_invalid
    if worked_request_sign.present?
      if started_at.present? && finished_at.present? && (next_day.present? && next_day == "false")
        errors.add(:started_at, "より早い時間は無効です。") if started_at > finished_at
      end
    end
  end
  
  def worked_request_sign_and_finished_at_is_invalid_without_a_started_at
    if worked_request_sign.present?
      errors.add(:started_at,"が必要です。") if started_at.blank? && finished_at.present?
    end
  end
  
  def worked_request_sign_and_started_at_is_invalid_without_a_finished_at
    if worked_request_sign.present?
      errors.add(:finished_at,"が必要です。") if started_at.present? && finished_at.blank?
    end
  end
  
end
