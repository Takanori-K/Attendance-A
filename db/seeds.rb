User.create!(name: "管理者",
             email: "sample@email.com",
             password: "password",
             password_confirmation: "password",
             admin: true)

User.create!(name: "上長A",
             email: "sample-1@email.com",
             password: "password",
             password_confirmation: "password",
             employee_number: "2",
             superior: true)

User.create!(name: "上長B",
             email: "sample-2@email.com",
             password: "password",
             password_confirmation: "password",
             employee_number: "3",
             superior: true)             

User.create!(name: "一般",
             email: "sample-3@email.com",
             password: "password",
             password_confirmation: "password",
             employee_number: "4")         