class Attendance < ApplicationRecord
  belongs_to :user
  
  validates :worked_on, presence: true
  validates :note, length: { maximum: 50 }
  #validates_acceptance_of :agreement, allow_nil: false, on: :update

  
  validate :finished_at_is_invalid_without_a_started_at
  validate :started_at_than_finished_at_fast_if_invalid
  validate :overtime_change?
  validate :month_request_change?
  validate :worked_request_sign_and_started_at_than_finished_at_fast_if_invalid
  validate :worked_request_sign_and_finished_at_is_invalid_without_a_started_at
  validate :worked_request_sign_and_started_at_is_invalid_without_a_finished_at
  
  enum overtime_status: { applying: 0, approval: 1, denial: 2 }
  enum month_status: { month_applying: 0, month_approval: 1, month_denial: 2 }
  
  def finished_at_is_invalid_without_a_started_at
    errors.add(:started_at,"が必要です。") if started_at.blank? && finished_at.present?
  end
  
  def started_at_than_finished_at_fast_if_invalid
    if started_at.present? && finished_at.present?
      errors.add(:started_at, "より早い時間は無効です。") if started_at > finished_at
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
  
  def worked_request_sign_and_started_at_than_finished_at_fast_if_invalid
    if worked_request_sin.present?
      errors.add(:started_at, "より早い時間は無効です。") if started_at > finished_at
    end
  end
  
  def worked_request_sign_and_finished_at_is_invalid_without_a_started_at
    if worked_request_sin.present?
      errors.add(:started_at,"が必要です。") if started_at.blank? && finished_at.present?
    end
  end
  
  def worked_request_sign_and_started_at_is_invalid_without_a_finished_at
    if worked_request_sin.present?
      errors.add(:finished_at,"が必要です。") if started_at.present? && finished_at.blank?
    end
  end
  
end
