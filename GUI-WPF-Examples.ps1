#Hello World
$window = New-Object Windows.Window
$window.Title = “Hello World”
$label = New-Object Windows.Controls.Label
$label.Content, $label.FontSize = “Hello World”, 24
$window.Content = $label
$window.SizeToContent = “WidthAndHeight”
$null = $window.ShowDialog()

function Show-Control {

param([Parameter(Mandatory=$true, ParameterSetName="VisualElement", ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)] [Windows.Media.Visual] $control, [Parameter(Mandatory=$true, ParameterSetName="Xaml", ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)] [string] $xaml, [Parameter(ValueFromPipelineByPropertyName=$true,Position=0)][Hashtable] $event, [Hashtable] $windowProperties)

  Begin

  {

      $window = New-Object Windows.Window

      $window.SizeToContent = "WidthAndHeight"

      if ($windowProperties) {

          foreach ($kv in $windowProperties.GetEnumerator()) {

              $window."$($kv.Key)" = $kv.Value

          }

      }

      $visibleElements = @()

      $windowEvents = @()

  }

  Process

  {      

      switch ($psCmdlet.ParameterSetName)

      {

      "Xaml" {

          $f = [System.xml.xmlreader]::Create([System.IO.StringReader] $xaml)

          $visibleElements+=([system.windows.markup.xamlreader]::load($f))      

      }

      "VisualElement" {

          $visibleElements+=$control

      }

      }

      if ($event) {

          $element = $visibleElements[-1]      

          foreach ($evt in $event.GetEnumerator()) {

              # If the event name is like *.*, it is an event on a named target, otherwise, it's on any of the events on the top level object

              if ($evt.Key.Contains(".")) {

                  $targetName = $evt.Key.Split(".")[1].Trim()

                  if ($evt.Key -like "Window.*") {

                      $target = $window

                  } else {

                      $target = ($visibleElements[-1]).FindName(($evt.Key.Split(".")[0]))                  

                  }                      

              } else {

                  $target = $visibleElements[-1]

                  $targetName = $evt.Key

              }

              $target | Get-Member -type Event |

                ? { $_.Name -eq $targetName } |

                % {

                  $eventMethod = $target."add_$targetName"

                  $eventMethod.Invoke($evt.Value)

                }              

          }

      }

   }

   End

   {

       if ($visibleElements.Count -gt 1) {

           $wrapPanel = New-Object Windows.Controls.WrapPanel

           $visibleElements | % { $null = $wrapPanel.Children.Add($_) }

           $window.Content = $wrapPanel

       } else {

           if ($visibleElements) {

               $window.Content = $visibleElements[0]

           }

       }

       $null = $window.ShowDialog()

   }

}

#calling the function to display Ink Canvas

"<InkCanvas xmlns='schemas.microsoft.com/.../presentation& />" | Show-Control

#Hello World in XAML
# XAML is an XML format you can use to write user interfaces that use WPF.
"<Label xmlns='http://schemas.microsoft.com/winfx/2006/xaml/presentation' FontSize='24'>Hello World</Label>" | Show-Control 

#Xaml Select Command
@" 
<StackPanel xmlns='http://schemas.microsoft.com/winfx/2006/xaml/presentation'> 
<Label FontSize='14'>Type a Command</Label> 
<TextBox Name="CommandTextBox"/> 
<ListBox Name="CommandListBox" Width='200' Height='200'/> 
<Button Name="SelectCommandButton" FontSize='14'>Select Command</Button> 
</StackPanel> 
"@ | Show-Control @{ 
   "CommandTextBox.TextChanged" = {       
       $listBox = $window.Content.FindName("CommandListBox") 
       $textBox = $window.Content.FindName("CommandTextBox") 
       $listBox.ItemsSource = @(Get-Command "*$($textbox.Text)*" | % { $_.Name }) 
   } 
   "CommandListBox.SelectionChanged" = { 
       $textBox = $window.Content.FindName("CommandTextBox") 
       $textBox.Text = $this.SelectedItem 
   } 
   "SelectCommandButton.Click" = {$window.Close()} 
}

#Label & Textbox (was 11 lines, now 6 lines)
@" 
<StackPanel xmlns='http://schemas.microsoft.com/winfx/2006/xaml/presentation'> 
<Label FontSize='20'>Type Something</Label> 
<TextBox /> 
</StackPanel> 
"@ |  Show-Control

#InkCanvas (was 7 lines, now 1 line):
"<InkCanvas xmlns='http://schemas.microsoft.com/winfx/2006/xaml/presentation' />" | Show-Control

#Random Circle (was 9 lines, now 6 lines in Xaml function)
$circleSize = Get-Random -min 200 -max 450 
$color = "Red", "Green","Blue","Orange","Yellow" | Get-Random 
"<Ellipse xmlns='http://schemas.microsoft.com/winfx/2006/xaml/presentation' 
  Width='$circleSize' 
  Height='$circleSize' 
  Fill='$color' />" |  Show-Control

#Create a Circle of a Random Size:
$window = New-Object Windows.Window
$color = (“Red”, “Green”,”Blue”,”Yellow” | Get-Random)
$window.Title = “See The Big $color Ball”
$circle = New-Object Windows.Shapes.Ellipse
$circle.Width = $circle.Height = Get-Random –min 200 –max 450
$circle.Fill = $color
$window.Content = $circle
$window.SizeToContent = “WidthAndHeight”
$null = $window.ShowDialog()
      
#Create an Ink Canvas the user can scribble on with the mouse or stylus       
$window = New-Object Windows.Window
$window.Title = “Scribble on Me”
$inkCanvas = New-Object Windows.Controls.InkCanvas
$inkCanvas.MinWidth = $inkCanvas.MinHeight = 100
$window.Content = $inkCanvas
$window.SizeToContent = “WidthAndHeight”
$null = $window.ShowDialog()

#Show a slider, and get the value the slider was at after running:
 
$window = new-object Windows.Window
$slider = New-Object Windows.Controls.Slider
$slider.Maximum = 10
$slider.Minimum = 0
$window.Content = $slider
$window.SizeToContent = "WidthAndHeight"
$null = $window.ShowDialog()
$slider.Value


#Show a label and textbox, and emit the value the textbox contained:
$window = new-object Windows.Window
$stackPanel = new-object Windows.Controls.StackPanel
$text = New-Object Windows.Controls.TextBox
$label = New-Object Windows.Controls.Label
$label.Content = "Type Something"
$stackPanel.Children.Add($label) 
$stackPanel.Children.Add($text)
$window.Content = $stackPanel
$window.SizeToContent = "WidthAndHeight"
$null = $window.ShowDialog()
$text.Text

#Drag & Drop (was 33 lines, now 31)
@" 
<StackPanel xmlns='http://schemas.microsoft.com/winfx/2006/xaml/presentation'> 
<Label FontSize='14'>Drag Scripts Here, DoubleClick to Run</Label> 
<ListBox Name="CommandListBox" AllowDrop='True' Height='200'/> 
<Button Name="RunCommandButton" FontSize='14'>Run File</Button> 
<Button Name="ClearCommandButton" FontSize='14'>Clear List</Button> 
</StackPanel> 
"@ | Show-Control @{ 
   "CommandListBox.MouseDoubleClick" = { 
       Invoke-Expression "$($this.SelectedItem)" -ea SilentlyContinue 
   } 
   "CommandListBox.Drop" = { 
       $files = $_.Data.GetFileDropList() 
       foreach ($file in $files) { 
           if ($file -is [IO.FileInfo]) { 
               $displayedFiles = $file 
           } else { 
               $displayedFiles += dir $file -recurse | ? { $_ -is [IO.FileInfo]} | % { $_.FullName } 
           }            
       } 
       $listBox.ItemsSource = $displayedFiles | sort    
   } 
   "RunCommandButton.Click" = { 
       $listBox = $window.Content.FindName("CommandListBox") 
       Invoke-Expression "$($listbox.SelectedItem)" -ea SilentlyContinue 
   } 
   "ClearCommandButton.Click" = { 
       $window.Content.FindName("CommandListBox").ItemsSource=@() 
   } 
}