User.create!(name:  "管理者",
             email: "email@sample.com",
             password:              "password",
             password_confirmation: "password",
             employee_number:        "1",
             uid:                    "111",
             admin: true)

User.create!(name: "上長A",
             email: "email2@sample.com",
             password:              "password",
             password_confirmation: "password",
             employee_number:       "2",
             uid:                   "222",
             superior: true)

User.create!(name: "上長B",
             email: "email3@sample.com",
             password:              "password",
             password_confirmation: "password",
             employee_number:       "3",
             uid:                   "333",
             superior: true)

User.create!(name: "一般",
             email: "email4@sample.com",
             password:              "password",
             password_confirmation: "password",
             employee_number:       "4",
             uid:                   "444")