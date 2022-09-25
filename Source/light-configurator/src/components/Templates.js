import { ColorButton } from "mui-color";

export function createMenuItemColorTemplateFunc(iconForAll) {

  const menuItemColorTemplateFunc = (item) => {
    if (item.id <= 1 && !iconForAll) {
      return item.name;
    }

    return (
      <div>
        <ColorButton color={item.id} /> <span>{item.name}</span>
      </div>);
  };

  return menuItemColorTemplateFunc;
}
