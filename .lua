-- Lâm Vĩ Quote System™
-- Tự động hiển thị 100 câu triết lý - tu tiên - ngôn tình
-- Random, fade 10s, lưu tiến trình tránh trùng

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local player = Players.LocalPlayer
local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
local label = Instance.new("TextLabel", gui)

label.Size = UDim2.new(0.6, 0, 0.2, 0)
label.Position = UDim2.new(0.2, 0, 0.4, 0)
label.BackgroundTransparency = 1
label.TextColor3 = Color3.fromRGB(255,255,255)
label.TextScaled = true
label.Font = Enum.Font.GothamBold
label.TextStrokeTransparency = 0.3
label.TextTransparency = 1
label.TextWrapped = true

local quotes = {
    "Kẻ yếu dựa vào may mắn, kẻ mạnh dựa vào bản thân.",
    "Tu tiên không phải là trốn đời, mà là nhìn thấu thế gian.",
    "Tình yêu giống như pháp bảo, không tu đúng cách sẽ tự hủy mình.",
    "Một thanh kiếm không thể sắc nếu chưa từng trải qua lửa.",
    "Người thắng là người cuối cùng còn đứng, không phải người đầu tiên ra tay.",
    "Tâm tĩnh như nước, kiếm mới vững như sơn.",
    "Hàn Lập từng nói: Con đường tu tiên, không có đúng sai, chỉ có sinh tồn.",
    "Một khi đã bước lên con đường này, ta chỉ còn thể tiến, không thể lùi.",
    "Đời người như ván cờ, thua một nước chưa chắc đã bại cả bàn.",
    "Ma hoàng không sinh ra để yêu, mà để khiến thiên hạ phải cúi đầu.",
    "Cảnh giới không ở trong tu vi, mà ở trong tâm.",
    "Tình yêu không phải phép màu, nó là con dao hai lưỡi.",
    "Ngươi nói yêu, nhưng ngươi có dám chết vì ta?",
    "Thế gian rộng lớn, chỉ có một người khiến ta quên đi tu hành.",
    "Người tu đạo sợ nhất là động tâm.",
    "Không có ma, chỉ có người tự biến mình thành ma.",
    "Đạo tâm vững, vạn pháp đều không ngại.",
    "Khi đã nếm đủ cô độc, người ta sẽ hiểu vì sao kẻ tu tiên thường vô tình.",
    "Ngọc nát còn hơn ngói lành.",
    "Đôi khi, tha thứ không phải vì họ xứng đáng, mà vì ta cần bình yên.",
    "Tu hành vạn năm, chẳng bằng một lần nhìn thấy nụ cười người ấy.",
    "Trời cao không tuyệt đường người có tâm.",
    "Người mạnh thật sự không cần chứng minh, họ khiến thiên hạ tự công nhận.",
    "Một chữ 'Tình' khiến vạn kiếp không siêu thoát.",
    "Nếu đã chọn bước vào biển khổ, thì phải biết bơi trong máu.",
    "Kiếm trong tay, tâm trong ngực, trời đất cũng chẳng thể ngăn ta.",
    "Cái giá của sức mạnh luôn là cô độc.",
    "Không có kẻ thù nào đáng sợ hơn chính bản thân mình.",
    "Đạo pháp vô biên, nhưng lòng người hữu hạn.",
    "Kẻ ngốc hỏi đường, kẻ thông minh tự mở đường.",
    "Nếu thế gian này không còn ánh sáng, ta sẽ tự thắp sáng chính mình.",
    "Người tu tiên thật sự, không tranh, không cầu, không động tâm.",
    "Tình yêu của người phàm là sợi xích trói kẻ tu tiên.",
    "Khi đã vô tâm, thì muôn sự đều an.",
    "Một giọt máu rơi, ngàn kiếp nhân quả.",
    "Ngươi cứu ta một lần, ta trả bằng cả kiếp này.",
    "Nếu không thể cùng nhau sống, ta nguyện cùng nhau diệt.",
    "Cái gọi là vĩnh hằng, chỉ là lời nói dối của người bất tử.",
    "Ta không cần thiên đạo cho phép, ta tự định đạo của mình.",
    "Thứ đáng sợ nhất không phải ma, mà là lòng người.",
    "Đời người như mộng, tỉnh rồi mới biết chỉ còn hư không.",
    "Không có ai sinh ra đã mạnh, chỉ là họ không còn lựa chọn nào khác.",
    "Ngươi muốn làm tiên, ta muốn làm người, cuối cùng đều hóa thành tro.",
    "Kẻ yêu sâu nhất, lại là kẻ bị thương nhiều nhất.",
    "Tâm đã chết, tu vi cũng vô nghĩa.",
    "Nếu có kiếp sau, ta nguyện làm phàm nhân, chỉ để được yêu ngươi một lần nữa.",
    "Kẻ nói vô tình, thật ra là kẻ đau nhất.",
    "Đôi khi im lặng còn đau hơn ngàn lời oán trách.",
    "Tình yêu không có đúng sai, chỉ có ai buông tay trước.",
    "Đời người không sợ không có đường, chỉ sợ không dám đi.",
    "Ngươi gọi ta là ma, nhưng chính lòng ngươi mới thật sự đen tối.",
    "Người ta nói tiên vô tình, nhưng tiên cũng từng là người.",
    "Ngươi cứu ta khỏi vực sâu, ta lại nguyện cùng ngươi rơi xuống.",
    "Chỉ khi mất đi, ta mới hiểu điều quý giá nhất.",
    "Khi con tim còn đập, đạo vẫn chưa tàn.",
    "Thiên hạ vạn vật, duy tâm vi căn.",
    "Không phải ta tàn nhẫn, chỉ là thế gian ép ta như vậy.",
    "Tình yêu như độc dược, biết hại mà vẫn muốn uống.",
    "Ta không muốn tu tiên, ta chỉ muốn tu lòng người.",
    "Sức mạnh càng lớn, trách nhiệm càng nặng.",
    "Không có con đường nào gọi là sai, chỉ có kẻ không dám bước tiếp.",
    "Khi yêu, ai cũng từng ngu ngốc.",
    "Tu hành không diệt tình, mà là hiểu rõ tình.",
    "Đừng sợ bóng tối, vì ánh sáng cũng từng từ đó mà sinh ra.",
    "Đời ta, chỉ cúi đầu trước người ta yêu.",
    "Nếu ngươi là định mệnh của ta, thì ta sẽ chống lại cả trời cao.",
    "Cái gì càng đẹp, càng dễ vỡ.",
    "Kẻ mạnh không phải không sợ, mà là dám tiến dù sợ.",
    "Chữ 'Tình' là một đạo khó tu nhất trong thiên hạ.",
    "Có những vết thương không cần lành, vì chúng nhắc ta còn sống.",
    "Đời người như mây bay, hợp rồi tan, tan rồi hợp.",
    "Tu tiên vạn năm, cuối cùng chỉ để học cách buông bỏ.",
    "Không có gì vĩnh viễn, kể cả lời thề son sắt.",
    "Nếu yêu là tội, ta nguyện phạm tội muôn kiếp.",
    "Khi lòng yên, gió cũng dừng.",
    "Người khôn ngoan không phải kẻ biết nhiều, mà là kẻ hiểu ít mà sâu.",
    "Một đời không cầu tiên vị, chỉ cầu một lần nắm tay người.",
    "Người thắng thiên hạ, lại thua một chữ tình.",
    "Thà cô độc trong mưa, còn hơn giả vờ cười dưới nắng.",
    "Tu vi cao đến đâu, cũng không bằng hiểu lòng người.",
    "Thế gian này, chỉ có kẻ dám mất tất cả mới thật sự tự do.",
    "Ngươi có thể thắng cả thiên hạ, nhưng không thể thắng lòng mình.",
    "Nếu số mệnh đã định, ta nguyện viết lại bằng máu.",
    "Người càng lạnh lùng, càng từng cháy bỏng.",
    "Một khi lòng đã nguội, ngàn năm cũng chẳng sưởi ấm được.",
    "Tình là độc, càng uống càng say.",
    "Đạo không ở trên trời, mà ở trong lòng người.",
    "Người chết đi, ký ức vẫn sống.",
    "Thứ khó tu nhất là tâm, thứ dễ mất nhất cũng là tâm.",
    "Ngươi từng cứu ta, giờ ta cứu ngươi, thế là đủ.",
    "Nếu thế gian không dung ta, ta sẽ tạo ra một thế gian khác.",
    "Chỉ cần còn một hơi thở, ta vẫn sẽ chiến đấu.",
    "Không ai sinh ra đã vô tình, chỉ là họ đã tổn thương quá nhiều.",
    "Ngươi nói yêu, nhưng có hiểu yêu là gì?",
    "Đôi khi, từ bỏ cũng là một cách yêu.",
    "Nếu có thể quay lại, ta vẫn chọn bước vào biển khổ ấy.",
    "Trời sinh ta ra không phải để cúi đầu.",
    "Người ta nói thời gian chữa lành, nhưng có vết thương chỉ ngủ quên thôi.",
    "Một đời tu tiên, đổi lấy một ánh mắt người thương, đáng hay không?",
    "Không có thiên đạo nào công bằng, chỉ có kẻ đủ mạnh để viết lại nó.",
    "Khi tim ngừng đau, tu vi mới thật sự thành.",
    "Yêu là đau, nhưng không yêu còn đau hơn."
}

-- Save progress
local filePath = "LVM_Quotes.json"
local used = {}
if isfile and readfile and writefile then
    if isfile(filePath) then
        used = HttpService:JSONDecode(readfile(filePath))
    end
end

-- Pick new quote
local available = {}
for i, q in ipairs(quotes) do
    if not table.find(used, i) then
        table.insert(available, i)
    end
end

if #available == 0 then
    used = {}
    available = {}
    for i = 1, #quotes do table.insert(available, i) end
end

local idx = available[math.random(1, #available)]
table.insert(used, idx)
if writefile then writefile(filePath, HttpService:JSONEncode(used)) end

label.Text = quotes[idx]

-- Fade in/out
for t = 0, 1, 0.05 do
    label.TextTransparency = 1 - t
    wait(0.05)
end
wait(10)
for t = 0, 1, 0.05 do
    label.TextTransparency = t
    wait(0.05)
end
label:Destroy()
