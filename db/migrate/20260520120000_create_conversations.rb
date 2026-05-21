# frozen_string_literal: true

class CreateConversations < ActiveRecord::Migration[8.1]
  def change
    create_table :conversations do |t|
      t.references :listable, polymorphic: true, null: false
      t.references :starter, null: false, foreign_key: { to_table: :users }
      t.string :subject, null: false
      t.datetime :last_message_at, null: false

      t.timestamps
    end

    add_index :conversations,
              %i[listable_type listable_id starter_id],
              unique: true,
              name: "index_conversations_on_listable_and_starter"

    create_table :conversation_participants do |t|
      t.references :conversation, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.datetime :last_read_at

      t.timestamps
    end

    add_index :conversation_participants,
              %i[conversation_id user_id],
              unique: true,
              name: "index_conversation_participants_on_conversation_and_user"

    create_table :conversation_messages do |t|
      t.references :conversation, null: false, foreign_key: true
      t.references :sender, null: false, foreign_key: { to_table: :users }
      t.text :body, null: false

      t.timestamps
    end

    add_index :conversation_messages, %i[conversation_id created_at]
  end
end
